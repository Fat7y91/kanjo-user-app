import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/address/data/model/address_model.dart';
import 'package:heraj/features/address/presentation/managers/address_provider.dart';
import 'package:heraj/features/address/presentation/view/address_details_screen.dart';
import 'package:heraj/features/cart/data/models/cart_item_model.dart';
import 'package:heraj/features/cart/domain/entities/cart_summary_entity.dart';
import 'package:heraj/features/cart/presentation/managers/checkout_actions_mixin.dart';
import 'package:heraj/features/cart/presentation/managers/checkout_providers.dart';
import 'package:heraj/features/rewards/data/models/reward_model.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:heraj/ui/ui.dart';
import 'package:intl/intl.dart';

import '../../../../config/app_font.dart';

const double _kCardRadius = 15;
const List<double> _kTipPresets = [0, 5, 10, 15, 20];

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen>
    with CheckoutActionsMixin {
  late final TextEditingController _couponController;
  late final TextEditingController _notesController;
  late final TextEditingController _customTipController;

  @override
  void initState() {
    super.initState();
    _couponController = TextEditingController();
    _notesController = TextEditingController();
    _customTipController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await ensureDefaultCheckoutAddress();
      try {
        final checkoutCart = await ref.read(checkoutCartProvider.future);
        if (!mounted) return;
        if (checkoutCart.cart.isEmpty) {
          Get.back();
          return;
        }
        final summary = checkoutCart.cart.summary;
        final existingCodes = <String>{
          ...ref.read(checkoutCouponCodesProvider),
          ...summary.couponCodes.where((c) => c.trim().isNotEmpty),
          if ((summary.couponCode ?? '').trim().isNotEmpty)
            summary.couponCode!.trim(),
        }.toList();
        if (existingCodes.isNotEmpty) {
          ref.read(checkoutCouponCodesProvider.notifier).state = existingCodes;
          if (ref.read(checkoutCouponCodeProvider).trim().isEmpty) {
            ref.read(checkoutCouponCodeProvider.notifier).state =
                existingCodes.first;
          }
          _couponController.text = existingCodes.join(', ');
        }
      } catch (_) {
        if (mounted) Get.back();
      }
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    _notesController.dispose();
    _customTipController.dispose();
    super.dispose();
  }

  String _money(double v) {
    final text = v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
    return '$text ${'EGP'.tr}';
  }

  Future<void> _pickAddress() async {
    final addresses = await showModalBottomSheet<AddressModel>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddressPickerSheet(),
    );
    if (addresses != null && mounted) {
      ref.read(checkoutSelectedAddressProvider.notifier).state = addresses;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(checkoutCartProvider);
    final payment = ref.watch(checkoutPaymentMethodProvider);
    final selectedAddress = ref.watch(checkoutSelectedAddressProvider);
    final tip = ref.watch(checkoutTipAmountProvider);
    final selectedReward = ref.watch(checkoutSelectedRewardProvider);
    final isApplyingCoupon = ref.watch(isLoadingProvider('applyCoupon'));
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    ref.listen<AsyncValue<CheckoutCartState>>(checkoutCartProvider, (
      previous,
      next,
    ) {
      final warning = next.valueOrNull?.deliveryWarning;
      final previousWarning = previous?.valueOrNull?.deliveryWarning;
      if (warning != null && warning != previousWarning) {
        UIHelper.showAlert(warning, type: DialogType.warning);
      }
    });

    return Scaffold(
      backgroundColor: AppColor.pageBackgroundGrey,
      body: cartAsync.customWhen(
        ref: ref,
        refreshable: checkoutCartProvider.future,
        skipLoadingOnReload: true,
        skipLoadingOnRefresh: true,
        skipError: true,
        loading: () => const PageLoadingWidget(),
        data: (checkoutCart) {
          final cart = checkoutCart.cart;
          final deliveryWarning = checkoutCart.deliveryWarning;
          final actionsEnabled = checkoutCart.actionsEnabled;
          if (cart.isEmpty) {
            return Center(
              child: Text(
                'Your cart is empty'.tr,
                style: AppFont.font16W500Black,
              ),
            );
          }

          final rewardDiscount =
              selectedReward?.discountAmountFor(cart.summary.displaySubtotal) ??
                  0;
          final total = cart.summary.payableTotal(
            userTip: tip,
            rewardDiscount: rewardDiscount,
          );

          return Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: _CheckoutAppBar(onBack: () => Get.back()),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _AddressMapCard(
                      address: selectedAddress,
                      onChange: _pickAddress,
                      onAdd: () async {
                        await Get.to(() => const AddressDetailsScreen());
                        ref.invalidate(fetchAddressesProvider);
                        await ensureDefaultCheckoutAddress();
                      },
                    ),
                    if (deliveryWarning != null) ...[
                      const Gap(12),
                      _DeliveryWarningBanner(message: deliveryWarning),
                    ],
                    const Gap(16),
                    _OrderItemsSection(
                      items: cart.items,
                      languageCode: languageCode,
                      money: _money,
                    ),
                    const Gap(16),
                    IgnorePointer(
                      ignoring: !actionsEnabled,
                      child: Opacity(
                        opacity: actionsEnabled ? 1 : 0.55,
                        child: _DeliveryTimeSection(
                          mode: ref.watch(checkoutDeliveryModeProvider),
                          scheduledAt:
                              ref.watch(checkoutScheduledDeliveryAtProvider),
                          onSelectMode: setCheckoutDeliveryMode,
                          onPickSchedule: pickCheckoutScheduledDateTime,
                        ),
                      ),
                    ),
                    const Gap(16),
                    IgnorePointer(
                      ignoring: !actionsEnabled,
                      child: Opacity(
                        opacity: actionsEnabled ? 1 : 0.55,
                        child: _PaymentSection(
                          selected: payment,
                          onSelect: (value) => ref
                              .read(checkoutPaymentMethodProvider.notifier)
                              .state = value,
                        ),
                      ),
                    ),
                    const Gap(16),
                    IgnorePointer(
                      ignoring: !actionsEnabled,
                      child: Opacity(
                        opacity: actionsEnabled ? 1 : 0.55,
                        child: _TipsSection(
                          selectedTip: tip,
                          customController: _customTipController,
                          onSelect: (value) {
                            ref.read(checkoutTipAmountProvider.notifier).state =
                                value;
                            if (!_kTipPresets.contains(value)) {
                              _customTipController.text = value % 1 == 0
                                  ? value.toStringAsFixed(0)
                                  : value.toStringAsFixed(2);
                            }
                          },
                        ),
                      ),
                    ),
                    const Gap(16),
                    _NotesSection(
                      controller: _notesController,
                      onChanged: (value) => ref
                          .read(checkoutNotesProvider.notifier)
                          .state = value,
                    ),
                    const Gap(16),
                    _CouponSection(
                      controller: _couponController,
                      isLoading: isApplyingCoupon,
                      enabled: actionsEnabled,
                      appliedCode: cart.summary.displayCouponCode.isNotEmpty
                          ? cart.summary.displayCouponCode
                          : ref.watch(checkoutCouponCodeProvider),
                      onApply: actionsEnabled
                          ? () => applyCheckoutCoupon(_couponController.text)
                          : null,
                    ),
                    const Gap(16),
                    IgnorePointer(
                      ignoring: !actionsEnabled,
                      child: Opacity(
                        opacity: actionsEnabled ? 1 : 0.55,
                        child: _RewardsSection(
                          selectedReward: selectedReward,
                          languageCode: languageCode,
                          discountText: selectedReward == null
                              ? null
                              : '- ${_money(rewardDiscount)}',
                          enabled: actionsEnabled,
                          onSelect: () => openCheckoutRewardsSheet(
                            orderAmount: cart.summary.displaySubtotal,
                          ),
                          onClear: clearCheckoutReward,
                        ),
                      ),
                    ),
                    const Gap(16),
                    _SummarySection(
                      summary: cart.summary,
                      tip: tip,
                      money: _money,
                      total: total,
                    ),
                  ],
                ),
              ),
              _CheckoutBottomBar(
                totalText: _money(total),
                enabled: actionsEnabled,
                isLoading: ref.watch(isLoadingProvider('checkout')),
                onConfirm: () => submitCheckout(cart),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CheckoutAppBar extends StatelessWidget {
  const _CheckoutAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 28,
            height: 28,
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: AppColor.textDark,
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Checkout screen title'.tr,
            style: AppFont.font18W700Black.copyWith(color: AppColor.textDark),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 28, height: 28),
      ],
    );
  }
}

class _AddressMapCard extends StatefulWidget {
  const _AddressMapCard({
    required this.address,
    required this.onChange,
    required this.onAdd,
  });

  final AddressModel? address;
  final VoidCallback onChange;
  final VoidCallback onAdd;

  @override
  State<_AddressMapCard> createState() => _AddressMapCardState();
}

class _AddressMapCardState extends State<_AddressMapCard> {
  static const _mapZoom = 15.0;
  GoogleMapController? _mapController;

  LatLng? get _target {
    final lat = widget.address?.latitude;
    final lng = widget.address?.longitude;
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  @override
  void didUpdateWidget(covariant _AddressMapCard oldWidget) {
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
        CameraPosition(target: target, zoom: _mapZoom),
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
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: AppColor.checkoutBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(_kCardRadius),
            ),
            child: SizedBox(
              height: 160,
              child: hasCoords
                  ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: target,
                        zoom: _mapZoom,
                      ),
                      onMapCreated: _onMapCreated,
                      markers: {
                        Marker(
                          markerId: const MarkerId('checkout_address'),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.address?.label.isNotEmpty == true
                            ? widget.address!.label
                            : 'Checkout no address'.tr,
                        style: AppFont.font16W700Black.copyWith(
                          color: AppColor.textDark,
                        ),
                      ),
                      const Gap(6),
                      Text(
                        widget.address?.address.isNotEmpty == true
                            ? widget.address!.address
                            : 'Checkout select address'.tr,
                        style: AppFont.font12w500Grey2.copyWith(
                          color: AppColor.textBodyTertiary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                InkWell(
                  onTap: widget.address == null ? widget.onAdd : widget.onChange,
                  child: Text(
                    (widget.address == null
                            ? 'Checkout add address'
                            : 'Checkout change address')
                        .tr,
                    style: AppFont.font14W700Black.copyWith(
                      color: AppColor.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColor.primary,
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

class _OrderItemsSection extends StatelessWidget {
  const _OrderItemsSection({
    required this.items,
    required this.languageCode,
    required this.money,
  });

  final List<CartItemModel> items;
  final String languageCode;
  final String Function(double) money;

  @override
  Widget build(BuildContext context) {
    final productItems =
        items.where((item) => !item.isCustomAddon).toList();
    final addonItems =
        items.where((item) => item.isCustomAddon).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: AppColor.checkoutBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Checkout items title'.tr,
            style: AppFont.font16W700Black,
          ),
          const Gap(12),
          for (var i = 0; i < productItems.length; i++) ...[
            if (i > 0) const Gap(10),
            _CheckoutItemRow(
              item: productItems[i],
              languageCode: languageCode,
              money: money,
            ),
          ],
          if (addonItems.isNotEmpty) ...[
            const Gap(12),
            Text(
              'Addons'.tr,
              style: AppFont.font14W700Black,
            ),
            const Gap(8),
            for (var i = 0; i < addonItems.length; i++) ...[
              if (i > 0) const Gap(8),
              _CheckoutAddonRow(
                item: addonItems[i],
                languageCode: languageCode,
                money: money,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _CheckoutItemRow extends StatelessWidget {
  const _CheckoutItemRow({
    required this.item,
    required this.languageCode,
    required this.money,
  });

  final CartItemModel item;
  final String languageCode;
  final String Function(double) money;

  @override
  Widget build(BuildContext context) {
    final title = item.product?.name.localized(languageCode) ?? '';
    final variant = item.variant?.name.localized(languageCode) ?? '';
    final additions = item.additions
        .map((e) => e.name.localized(languageCode))
        .where((e) => e.isNotEmpty)
        .join(', ');

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ImageOrSvg(
            item.variant?.imageUrl ?? item.product?.thumbnailImageUrl,
            width: 54,
            height: 54,
            fit: BoxFit.cover,
            pickImageOnNull: true,
            assetImageOnNull: AppAssets.homeCategoryFood,
          ),
        ),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFont.font14W700Black,
              ),
              if (variant.isNotEmpty) ...[
                const Gap(2),
                Text(
                  variant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.font12w500Grey2,
                ),
              ],
              if (additions.isNotEmpty) ...[
                const Gap(2),
                Text(
                  additions,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.font12w500Grey2.copyWith(
                    color: AppColor.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const Gap(8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'x${item.quantity}',
              style: AppFont.font12w500Grey2,
            ),
            const Gap(4),
            _CheckoutItemPrice(item: item, money: money),
          ],
        ),
      ],
    );
  }
}

class _CheckoutItemPrice extends StatelessWidget {
  const _CheckoutItemPrice({
    required this.item,
    required this.money,
  });

  final CartItemModel item;
  final String Function(double) money;

  @override
  Widget build(BuildContext context) {
    final showOriginal = item.originalUnitPrice > item.unitPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (showOriginal)
          Text(
            money(item.originalUnitPrice),
            style: AppFont.font12w500Grey2.copyWith(
              color: AppColor.textBodyTertiary,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColor.textBodyTertiary,
            ),
          ),
        Text(
          money(item.unitPrice),
          style: AppFont.font14W700Black.copyWith(
            color: AppColor.guestOrange,
          ),
        ),
      ],
    );
  }
}

class _CheckoutAddonRow extends StatelessWidget {
  const _CheckoutAddonRow({
    required this.item,
    required this.languageCode,
    required this.money,
  });

  final CartItemModel item;
  final String languageCode;
  final String Function(double) money;

  @override
  Widget build(BuildContext context) {
    final addonTitle = item.addonName.localized(languageCode);
    final title =
        addonTitle.isNotEmpty ? addonTitle : 'Custom addon'.tr;
    final vendorName = item.vendor?.name.trim() ?? '';
    final subtitle = vendorName.isNotEmpty
        ? 'Addon from @vendor'.trParams({'vendor': vendorName})
        : 'Custom addon'.tr;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFont.font14W700Black,
              ),
              const Gap(2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFont.font12w500Grey2,
              ),
            ],
          ),
        ),
        const Gap(8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'x${item.quantity}',
              style: AppFont.font12w500Grey2,
            ),
            const Gap(4),
            Text(
              money(item.lineTotal),
              style: AppFont.font14W700Black.copyWith(
                color: AppColor.guestOrange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DeliveryTimeSection extends StatelessWidget {
  const _DeliveryTimeSection({
    required this.mode,
    required this.scheduledAt,
    required this.onSelectMode,
    required this.onPickSchedule,
  });

  final CheckoutDeliveryMode mode;
  final DateTime? scheduledAt;
  final ValueChanged<CheckoutDeliveryMode> onSelectMode;
  final VoidCallback onPickSchedule;

  String _scheduledLabel(BuildContext context) {
    if (scheduledAt == null) return 'Checkout pick date time'.tr;
    final locale = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    return DateFormat('EEE, d MMM • h:mm a', locale).format(scheduledAt!);
  }

  @override
  Widget build(BuildContext context) {
    final isSchedule = mode == CheckoutDeliveryMode.schedule;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Checkout delivery title'.tr,
          style: AppFont.font16W700Black,
        ),
        const Gap(12),
        _DeliveryModeTile(
          selected: mode == CheckoutDeliveryMode.asap,
          title: 'Checkout delivery asap'.tr,
          subtitle: 'Checkout delivery eta'.tr,
          icon: Icons.bolt_rounded,
          onTap: () => onSelectMode(CheckoutDeliveryMode.asap),
        ),
        const Gap(10),
        _DeliveryModeTile(
          selected: isSchedule,
          title: 'Checkout delivery schedule'.tr,
          subtitle: isSchedule ? _scheduledLabel(context) : null,
          icon: Icons.schedule_rounded,
          onTap: () {
            onSelectMode(CheckoutDeliveryMode.schedule);
            if (scheduledAt == null) onPickSchedule();
          },
        ),
        if (isSchedule) ...[
          const Gap(10),
          Material(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(_kCardRadius),
            child: InkWell(
              onTap: onPickSchedule,
              borderRadius: BorderRadius.circular(_kCardRadius),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_kCardRadius),
                  border: Border.all(color: AppColor.checkoutBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 22,
                      color: AppColor.primary,
                    ),
                    const Gap(10),
                    Expanded(
                      child: Text(
                        _scheduledLabel(context),
                        style: AppFont.font14W500Black.copyWith(
                          color: AppColor.textDark,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.edit_calendar_outlined,
                      size: 20,
                      color: AppColor.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DeliveryModeTile extends StatelessWidget {
  const _DeliveryModeTile({
    required this.selected,
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
  });

  final bool selected;
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.white,
      borderRadius: BorderRadius.circular(_kCardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_kCardRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_kCardRadius),
            border: Border.all(
              color: selected ? AppColor.primary : AppColor.checkoutBorder,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColor.primary),
              const Gap(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFont.font14W500Black.copyWith(
                        color: AppColor.textDark,
                      ),
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                      const Gap(4),
                      Text(
                        subtitle!,
                        style: AppFont.font12w400Black.copyWith(
                          color: const Color(0xFF808080),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected ? AppColor.primary : AppColor.radioBorderGrey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({
    required this.selected,
    required this.onSelect,
  });

  final CheckoutPaymentMethod selected;
  final ValueChanged<CheckoutPaymentMethod> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Checkout pay with'.tr,
          style: AppFont.font16W700Black,
        ),
        const Gap(12),
        _PaymentTile(
          method: CheckoutPaymentMethod.cash,
          selected: selected,
          onSelect: onSelect,
          titleKey: 'Checkout payment cash',
          icon: Icons.payments_outlined,
        ),
      ],
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.onSelect,
    required this.titleKey,
    required this.icon,
  });

  final CheckoutPaymentMethod method;
  final CheckoutPaymentMethod selected;
  final ValueChanged<CheckoutPaymentMethod> onSelect;
  final String titleKey;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isOn = selected == method;
    return Material(
      color: AppColor.white,
      borderRadius: BorderRadius.circular(_kCardRadius),
      child: InkWell(
        onTap: () => onSelect(method),
        borderRadius: BorderRadius.circular(_kCardRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_kCardRadius),
            border: Border.all(
              color: isOn ? AppColor.primary : AppColor.checkoutBorder,
              width: isOn ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColor.primary),
              const Gap(10),
              Expanded(
                child: Text(
                  titleKey.tr,
                  style: AppFont.font14W500Black.copyWith(
                    color: AppColor.textDark,
                  ),
                ),
              ),
              Icon(
                isOn ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isOn ? AppColor.primary : AppColor.radioBorderGrey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipsSection extends StatelessWidget {
  const _TipsSection({
    required this.selectedTip,
    required this.customController,
    required this.onSelect,
  });

  final double selectedTip;
  final TextEditingController customController;
  final ValueChanged<double> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: AppColor.checkoutBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Checkout tip title'.tr, style: AppFont.font16W700Black),
          const Gap(12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final amount in _kTipPresets)
                _TipChip(
                  label: amount == 0
                      ? 'Checkout tip none'.tr
                      : '${amount.toStringAsFixed(0)} ${'EGP'.tr}',
                  selected: selectedTip == amount &&
                      customController.text.trim().isEmpty,
                  onTap: () {
                    customController.clear();
                    onSelect(amount);
                  },
                ),
            ],
          ),
          const Gap(10),
          TextField(
            controller: customController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppFont.font14W500Black,
            decoration: InputDecoration(
              hintText: 'Checkout tip custom'.tr,
              hintStyle: AppFont.font14W500Black.copyWith(
                color: AppColor.textGrey,
              ),
              filled: true,
              fillColor: const Color(0xFFF7F7F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              final parsed = double.tryParse(value.trim());
              if (parsed != null && parsed >= 0) {
                onSelect(parsed);
              } else if (value.trim().isEmpty) {
                onSelect(0);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _TipChip extends StatelessWidget {
  const _TipChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF7EFFF) : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColor.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: AppFont.font12w500Grey2.copyWith(
            color: selected ? AppColor.primary : AppColor.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _RewardsSection extends StatelessWidget {
  const _RewardsSection({
    required this.selectedReward,
    required this.languageCode,
    required this.enabled,
    required this.onSelect,
    required this.onClear,
    this.discountText,
  });

  final RewardModel? selectedReward;
  final String languageCode;
  final String? discountText;
  final bool enabled;
  final VoidCallback onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final selected = selectedReward;
    final name = selected?.name.localized(languageCode) ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: AppColor.checkoutBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Checkout rewards title'.tr, style: AppFont.font16W700Black),
          const Gap(10),
          if (selected != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppFont.font14W700Black,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(4),
                      Text(
                        '@count Points'.trParams({
                          'count': '${selected.requiredPoints}',
                        }),
                        style: AppFont.font12w500Grey2.copyWith(
                          color: AppColor.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (discountText != null) ...[
                  const Gap(8),
                  Text(
                    discountText!,
                    style: AppFont.font14W700Black.copyWith(
                      color: AppColor.guestOrange,
                    ),
                  ),
                ],
                IconButton(
                  onPressed: enabled ? onClear : null,
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColor.textBodySecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
            const Gap(8),
          ],
          SizedBox(
            width: double.infinity,
            child: CustomFilledButton(
              text: selected == null
                  ? 'Select a reward'.tr
                  : 'Checkout change reward'.tr,
              gradient: AppColor.defaultPrimaryGradient2,
              radius: 12,
              isValid: enabled,
              onPressed: enabled ? onSelect : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: AppColor.checkoutBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Checkout notes title'.tr, style: AppFont.font16W700Black),
          const Gap(10),
          TextField(
            controller: controller,
            maxLines: 3,
            style: AppFont.font14W500Black,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Checkout notes placeholder'.tr,
              hintStyle: AppFont.font14W500Black.copyWith(
                color: AppColor.textGrey,
              ),
              filled: true,
              fillColor: const Color(0xFFF7F7F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponSection extends StatelessWidget {
  const _CouponSection({
    required this.controller,
    required this.isLoading,
    required this.appliedCode,
    this.enabled = true,
    this.onApply,
  });

  final TextEditingController controller;
  final bool isLoading;
  final String appliedCode;
  final bool enabled;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    final canApply = enabled && !isLoading;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: AppColor.checkoutBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Checkout promo title'.tr, style: AppFont.font16W700Black),
          if (appliedCode.isNotEmpty) ...[
            const Gap(6),
            Text(
              '${'Coupon applied'.tr}: $appliedCode',
              style: AppFont.font12w500Grey2.copyWith(color: AppColor.primary),
            ),
          ],
          const Gap(10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  readOnly: !enabled,
                  style: AppFont.font14W500Black,
                  decoration: InputDecoration(
                    hintText: 'Checkout promo placeholder'.tr,
                    hintStyle: AppFont.font14W500Black.copyWith(
                      color: AppColor.textGrey,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF7F7F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const Gap(8),
              SizedBox(
                width: 110,
                child: CustomFilledButton(
                  text: 'Checkout promo apply'.tr,
                  isLoading: isLoading,
                  isValid: canApply,
                  gradient: AppColor.defaultPrimaryGradient2,
                  radius: 12,
                  onPressed: canApply ? onApply : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({
    required this.summary,
    required this.tip,
    required this.money,
    required this.total,
  });

  final CartSummaryEntity summary;
  final double tip;
  final String Function(double) money;
  final double total;

  @override
  Widget build(BuildContext context) {
    final displayTip = summary.displayTip(tip);
    final coupons = summary.displayCoupons;
    final appliedCouponCodes = summary.couponCodes
        .map((code) => code.trim())
        .where((code) => code.isNotEmpty)
        .toList();
    final hasAppliedCoupons = coupons.isNotEmpty ||
        appliedCouponCodes.isNotEmpty ||
        summary.displayCouponCode.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: AppColor.checkoutBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Checkout summary title'.tr,
                  style: AppFont.font16W700Black,
                ),
              ),
              if (summary.hasOffer)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.priceStrikeRed.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Cart has offer'.tr,
                    style: AppFont.font12W600Primary.copyWith(
                      color: AppColor.priceStrikeRed,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const Gap(12),
          _SummaryRow(
            label: 'Checkout summary subtotal'.tr,
            value: money(summary.subtotal),
          ),
          const Gap(8),
          _SummaryRow(
            label: 'Checkout summary discount'.tr,
            value: '- ${money(summary.productDiscount)}',
          ),
          const Gap(8),
          _SummaryRow(
            label: 'Checkout final shipping'.tr,
            value: money(summary.finalShipping),
          ),
          const Gap(8),
          _SummaryRow(
            label: 'Checkout summary service fee'.tr,
            value: money(summary.serviceFee),
          ),
          const Gap(8),
          _SummaryRow(
            label: 'Checkout summary vat'.tr,
            value: money(summary.vatTotal),
          ),
          if (summary.cashbackAmount > 0) ...[
            const Gap(8),
            _SummaryRow(
              label: 'Checkout summary cashback'.tr,
              value: money(summary.cashbackAmount),
            ),
          ],
          if (displayTip > 0) ...[
            const Gap(8),
            _SummaryRow(
              label: 'Checkout summary tip'.tr,
              value: money(displayTip),
            ),
          ],
          if (summary.appliedOffers.isNotEmpty || hasAppliedCoupons) ...[
            const Gap(12),
            const Divider(height: 1),
            const Gap(12),
            if (summary.appliedOffers.isNotEmpty) ...[
              Text(
                'Checkout applied offers'.tr,
                style: AppFont.font14W700Black.copyWith(
                  color: AppColor.textDark,
                ),
              ),
              for (final offer in summary.appliedOffers) ...[
                const Gap(8),
                _SummaryRow(
                  label: offer.name.isNotEmpty
                      ? offer.name
                      : 'Checkout applied offer'.tr,
                  value: '- ${money(offer.savings)}',
                ),
              ],
            ],
            if (hasAppliedCoupons) ...[
              const Gap(12),
              Text(
                'Checkout coupons'.tr,
                style: AppFont.font14W700Black.copyWith(
                  color: AppColor.textDark,
                ),
              ),
              if (coupons.isNotEmpty)
                for (final coupon in coupons) ...[
                  const Gap(8),
                  _SummaryRow(
                    label: coupon.displayTitle.isNotEmpty
                        ? coupon.displayTitle
                        : 'Checkout summary coupon'.tr,
                    value: '- ${money(coupon.discountAmount)}',
                  ),
                  if (coupon.shippingDiscount > 0) ...[
                    const Gap(8),
                    _SummaryRow(
                      label: 'Checkout coupon shipping discount'.tr,
                      value: '- ${money(coupon.shippingDiscount)}',
                    ),
                  ],
                  if (coupon.cashbackAmount > 0) ...[
                    const Gap(8),
                    _SummaryRow(
                      label: 'Checkout coupon cashback'.tr,
                      value: money(coupon.cashbackAmount),
                    ),
                  ],
                ]
              else
                for (final code in appliedCouponCodes.isNotEmpty
                    ? appliedCouponCodes
                    : [summary.displayCouponCode]) ...[
                  const Gap(8),
                  _SummaryRow(
                    label: code,
                    value: '- ${money(summary.couponDiscount)}',
                  ),
                ],
            ],
          ],
          if (summary.couponErrors.isNotEmpty) ...[
            const Gap(8),
            Text(
              summary.couponErrors.join('\n'),
              style: AppFont.font12w500Grey2.copyWith(
                color: AppColor.primary,
              ),
            ),
          ],
          const Gap(10),
          const Divider(height: 1),
          const Gap(10),
          _SummaryRow(
            label: 'Checkout summary total'.tr,
            value: money(total),
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.strikeThrough = false,
  });

  final String label;
  final String value;
  final bool emphasize;
  final bool strikeThrough;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: emphasize
                ? AppFont.font16W700Black
                : AppFont.font14W500Black.copyWith(
                    color: AppColor.textBodySecondary,
                  ),
          ),
        ),
        Text(
          value,
          style: emphasize
              ? AppFont.font16W700Black.copyWith(color: AppColor.guestOrange)
              : AppFont.font14W700Black.copyWith(
                  color: strikeThrough
                      ? AppColor.priceStrikeRed
                      : AppColor.textDark,
                  decoration:
                      strikeThrough ? TextDecoration.lineThrough : null,
                  decorationColor: AppColor.priceStrikeRed,
                ),
        ),
      ],
    );
  }
}

class _CheckoutBottomBar extends StatelessWidget {
  const _CheckoutBottomBar({
    required this.totalText,
    required this.onConfirm,
    this.enabled = true,
    this.isLoading = false,
  });

  final String totalText;
  final VoidCallback onConfirm;
  final bool enabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withAlpha(13),
            offset: const Offset(0, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: CustomFilledButton(
                  text: 'Confirm order'.tr,
                  gradient: AppColor.defaultPrimaryGradient2,
                  isValid: enabled,
                  isLoading: isLoading,
                  onPressed: enabled ? onConfirm : null,
                ),
              ),
              const Gap(12),
              Text(
                totalText,
                style: AppFont.font18W700Black.copyWith(
                  color: AppColor.guestOrange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeliveryWarningBanner extends StatelessWidget {
  const _DeliveryWarningBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.guestOrange.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.guestOrange.withAlpha(90)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColor.guestOrange,
            size: 22,
          ),
          const Gap(8),
          Expanded(
            child: Text(
              message,
              style: AppFont.font12w500Grey2.copyWith(
                color: AppColor.textDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressPickerSheet extends ConsumerWidget {
  const _AddressPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(fetchAddressesProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.paddingOf(context).bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColor.grey1,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const Gap(16),
            Text('Checkout select address'.tr, style: AppFont.font18W700Black),
            const Gap(12),
            Flexible(
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
                    shrinkWrap: true,
                    itemCount: addresses.length,
                    separatorBuilder: (_, __) => const Gap(8),
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColor.checkoutBorder),
                        ),
                        leading: Icon(
                          Icons.location_on_outlined,
                          color: AppColor.primary,
                        ),
                        title: Text(
                          address.label,
                          style: AppFont.font14W700Black,
                        ),
                        subtitle: Text(
                          address.address,
                          style: AppFont.font12w500Grey2,
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
      ),
    );
  }
}
