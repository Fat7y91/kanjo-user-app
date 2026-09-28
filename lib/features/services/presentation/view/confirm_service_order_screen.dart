import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/auth_service.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/address/data/model/address_model.dart';
import 'package:heraj/features/address/presentation/managers/address_provider.dart';
import 'package:heraj/features/address/presentation/view/address_details_screen.dart';
import 'package:heraj/features/cart/presentation/managers/checkout_actions_mixin.dart';
import 'package:heraj/features/cart/presentation/managers/checkout_providers.dart';
import 'package:heraj/features/services/domain/entities/create_service_order_params.dart';
import 'package:heraj/features/services/domain/entities/provider_service_entity.dart';
import 'package:heraj/features/services/presentation/managers/services_actions_mixin.dart';
import 'package:heraj/features/services/presentation/managers/services_provider.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:heraj/ui/ui.dart';

class ConfirmServiceOrderScreen extends ConsumerStatefulWidget {
  const ConfirmServiceOrderScreen({
    super.key,
    required this.provider,
    required this.service,
    required this.scheduledDate,
    required this.scheduledTime,
  });

  final ServiceProviderEntity provider;
  final ProviderServiceEntity service;
  final DateTime scheduledDate;
  final String scheduledTime;

  @override
  ConsumerState<ConfirmServiceOrderScreen> createState() =>
      _ConfirmServiceOrderScreenState();
}

class _ConfirmServiceOrderScreenState
    extends ConsumerState<ConfirmServiceOrderScreen>
    with CheckoutActionsMixin, BookServiceActionsMixin {
  static const _mapZoom = 15.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ensureDefaultCheckoutAddress();
    });
  }

  Future<void> _pickAddress() async {
    final address = await showModalBottomSheet<AddressModel>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ServiceAddressPickerSheet(),
    );
    if (address != null && mounted) {
      ref.read(checkoutSelectedAddressProvider.notifier).state = address;
    }
  }

  String _dateLabel() {
    final date = widget.scheduledDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dayMonth = '${date.day}/${date.month}';
    final selected = DateTime(date.year, date.month, date.day);
    if (selected == today) return '$dayMonth ${'Today'.tr}';
    if (selected == tomorrow) return '$dayMonth ${'Tomorrow'.tr}';
    return dayMonth;
  }

  Future<void> _completeOrder() async {
    final address = ref.read(checkoutSelectedAddressProvider);
    if (address == null ||
        address.latitude == null ||
        address.longitude == null) {
      UIHelper.showAlert(
        'Please select a location'.tr,
        type: DialogType.warning,
      );
      return;
    }
    final ok = await submitServiceOrder(
      CreateServiceOrderParams(
        providerServiceId: widget.service.id,
        scheduledDate:
            '${widget.scheduledDate.year.toString().padLeft(4, '0')}-'
            '${widget.scheduledDate.month.toString().padLeft(2, '0')}-'
            '${widget.scheduledDate.day.toString().padLeft(2, '0')}',
        scheduledTime: widget.scheduledTime,
        latitude: address.latitude!,
        longitude: address.longitude!,
        paymentMethod: 'cod',
        addressText: address.address.isNotEmpty ? address.address : address.label,
      ),
    );
    if (!ok || !mounted) return;
    Get.close(2);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final address = ref.watch(checkoutSelectedAddressProvider);
    final user = ref.watch(userProvider);
    final isSubmitting = ref.watch(isLoadingProvider('createServiceOrder'));
    final phone = user?.phone?.trim() ?? '';

    return Scaffold(
      backgroundColor: AppColor.white,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Get.back(),
                            icon: Icon(
                              Icons.arrow_back_ios,
                              size: 18,
                              color: AppColor.black,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Confirm order'.tr,
                              textAlign: TextAlign.center,
                              style: AppFont.font16W400Black.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Receipt method'.tr,
                          style: AppFont.font16W700Black,
                        ),
                        const Gap(12),
                        _ServiceAddressMapCard(
                          address: address,
                          phone: phone,
                          mapZoom: _mapZoom,
                          onChange: _pickAddress,
                          onAdd: () async {
                            await Get.to(() => const AddressDetailsScreen());
                            ref.invalidate(fetchAddressesProvider);
                            await ensureDefaultCheckoutAddress();
                          },
                        ),
                        const Gap(20),
                        Text(
                          'Booking'.tr,
                          style: AppFont.font16W700Black,
                        ),
                        const Gap(12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColor.lightBorder),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _ReadOnlyField(
                                  label: 'Date'.tr,
                                  value: _dateLabel(),
                                ),
                              ),
                              const Gap(10),
                              Expanded(
                                child: _ReadOnlyField(
                                  label: 'Time'.tr,
                                  value: widget.scheduledTime,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(20),
                        Text(
                          'Pay via'.tr,
                          style: AppFont.font16W700Black,
                        ),
                        const Gap(12),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColor.lightBorder),
                          ),
                          child: const _PaymentOptionTile(
                            method: ServicePaymentMethod.cod,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + bottom),
            child: CustomFilledButton(
              text: 'Complete order'.tr,
              height: 48,
              width: MediaQuery.sizeOf(context).width - 32,
              gradient: AppColor.defaultPrimaryGradient2,
              radius: 30,
              isLoading: isSubmitting,
              onPressed: isSubmitting ? null : _completeOrder,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFont.font12w400Black.copyWith(
          color: AppColor.textGrey,
        )),
        const Gap(6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.lightBorder),
          ),
          child: Text(value, style: AppFont.font14W600Black),
        ),
      ],
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  const _PaymentOptionTile({required this.method});

  final ServicePaymentMethod method;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.payments_outlined, size: 22, color: AppColor.primary),
          const Gap(10),
          Expanded(
            child: Text(
              method.label.tr,
              style: AppFont.font14W500Black,
            ),
          ),
          Icon(
            Icons.radio_button_checked,
            color: AppColor.primary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _ServiceAddressMapCard extends StatefulWidget {
  const _ServiceAddressMapCard({
    required this.address,
    required this.phone,
    required this.mapZoom,
    required this.onChange,
    required this.onAdd,
  });

  final AddressModel? address;
  final String phone;
  final double mapZoom;
  final VoidCallback onChange;
  final VoidCallback onAdd;

  @override
  State<_ServiceAddressMapCard> createState() => _ServiceAddressMapCardState();
}

class _ServiceAddressMapCardState extends State<_ServiceAddressMapCard> {
  GoogleMapController? _mapController;

  LatLng? get _target {
    final lat = widget.address?.latitude;
    final lng = widget.address?.longitude;
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  @override
  void didUpdateWidget(covariant _ServiceAddressMapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _target;
    if (next == null) return;
    final prevLat = oldWidget.address?.latitude;
    final prevLng = oldWidget.address?.longitude;
    if (prevLat == next.latitude && prevLng == next.longitude) return;
    _animateTo(next);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    final target = _target;
    if (target == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _animateTo(target);
    });
  }

  void _animateTo(LatLng target) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: widget.mapZoom),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final target = _target;
    final hasCoords = target != null;
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 160,
              child: hasCoords
                  ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: target,
                        zoom: widget.mapZoom,
                      ),
                      onMapCreated: _onMapCreated,
                      markers: {
                        Marker(
                          markerId: const MarkerId('service_address'),
                          position: target,
                        ),
                      },
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      compassEnabled: false,
                      mapToolbarEnabled: false,
                      scrollGesturesEnabled: false,
                      zoomGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                    )
                  : Container(
                      color: Colors.black.withAlpha(13),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 56,
                        color: AppColor.primary,
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: ImageOrSvg(
                    AppAssets.serviceLocation,
                    width: 18,
                    height: 18,
                    isLocal: true,
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.address?.label.isNotEmpty == true
                            ? widget.address!.label
                            : 'Checkout no address'.tr,
                        style: AppFont.font14W700Black,
                      ),
                      const Gap(4),
                      Text(
                        widget.address?.address.isNotEmpty == true
                            ? widget.address!.address
                            : 'Checkout select address'.tr,
                        style: AppFont.font12w400Black.copyWith(
                          color: AppColor.textGrey,
                          height: 1.4,
                        ),
                      ),
                      if (widget.phone.isNotEmpty) ...[
                        const Gap(6),
                        Text(
                          '${'Mobile number'.tr} : ${widget.phone}',
                          style: AppFont.font12w400Black.copyWith(
                            color: AppColor.textGrey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Gap(8),
                InkWell(
                  onTap:
                      widget.address == null ? widget.onAdd : widget.onChange,
                  child: Text(
                    'Change'.tr,
                    style: AppFont.font14W700Black.copyWith(
                      color: AppColor.guestOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceAddressPickerSheet extends ConsumerWidget {
  const _ServiceAddressPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(fetchAddressesProvider);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColor.lightBorder,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Gap(12),
          SizedBox(
            height: 280,
            child: addressesAsync.customWhen(
              ref: ref,
              refreshable: fetchAddressesProvider.future,
              loading: () => const PageLoadingWidget(),
              data: (addresses) {
                if (addresses.isEmpty) {
                  return Center(
                    child: Text(
                      'Checkout no address'.tr,
                      style: AppFont.font14W500Black,
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: addresses.length,
                  separatorBuilder: (_, __) => const Gap(8),
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColor.lightBorder),
                      ),
                      leading: Icon(
                        Icons.location_on_outlined,
                        color: AppColor.primary,
                      ),
                      title: Text(address.label, style: AppFont.font14W700Black),
                      subtitle: Text(
                        address.address,
                        style: AppFont.font12w400Black.copyWith(
                          color: AppColor.textGrey,
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(address),
                    );
                  },
                );
              },
            ),
          ),
          const Gap(12),
          CustomFilledButton(
            text: 'Checkout add address'.tr,
            gradient: AppColor.defaultPrimaryGradient2,
            onPressed: () async {
              await Get.to(() => const AddressDetailsScreen());
              ref.invalidate(fetchAddressesProvider);
            },
          ),
        ],
      ),
    );
  }
}
