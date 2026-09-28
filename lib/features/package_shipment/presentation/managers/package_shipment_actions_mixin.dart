import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/image_picker_cropper.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/core/service/location_service/location_service.dart';
import 'package:heraj/features/address/data/model/address_model.dart';
import 'package:heraj/features/address/presentation/managers/address_provider.dart';
import 'package:heraj/features/address/presentation/view/address_details_screen.dart';
import 'package:heraj/features/address/presentation/view/map_selector_screen.dart';
import 'package:heraj/features/package_shipment/domain/entities/package_dropoff_input.dart';
import 'package:heraj/features/package_shipment/domain/entities/package_shipment_params.dart';
import 'package:heraj/features/package_shipment/domain/use_case/package_shipment_use_cases.dart';
import 'package:heraj/features/package_shipment/presentation/managers/package_shipment_provider.dart';
import 'package:heraj/features/package_shipment/presentation/view/package_shipment_details_screen.dart';
import 'package:heraj/features/package_shipment/presentation/view/widgets/dropoff_details_sheet.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:heraj/ui/ui.dart';

mixin PackageShipmentActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  static const calculateLoadingKey = 'calculatePackagePrice';
  static const createLoadingKey = 'createPackageShipment';
  static String cancelLoadingKey(String id) => 'cancelPackageShipment_$id';

  Future<void> ensureDefaultPickupAddress() async {
    final current = ref.read(packageShipmentDraftProvider).pickupAddress;
    if (current != null) return;
    try {
      final addresses = await ref.read(fetchAddressesProvider.future);
      if (!mounted || addresses.isEmpty) return;
      AddressModel? selected;
      for (final address in addresses) {
        if (address.isDefault) {
          selected = address;
          break;
        }
      }
      selected ??= addresses.first;
      ref.read(packageShipmentDraftProvider.notifier).setPickup(selected);
    } catch (_) {}
  }

  Future<AddressModel?> pickPickupAddress() async {
    final selected = await showModalBottomSheet<AddressModel>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _PackageAddressPickerSheet(),
    );
    if (selected != null && mounted) {
      ref.read(packageShipmentDraftProvider.notifier).setPickup(selected);
    }
    return selected;
  }

  Future<PackageDropoffInput?> pickDropoffOnMap({
    PackageDropoffInput? existing,
  }) async {
    final initial = existing != null &&
            existing.dropoffLat != 0 &&
            existing.dropoffLng != 0
        ? [existing.dropoffLng, existing.dropoffLat]
        : null;
    final coords = await Get.to<List<double>>(
      () => MapSelectorScreen(initialCoordinates: initial),
    );
    if (coords == null || coords.length < 2 || !mounted) return null;

    final lng = coords[0];
    final lat = coords[1];
    final location = await getIt<LocationService>().geocodeLocation(lat, lng);
    if (!mounted) return null;

    return showModalBottomSheet<PackageDropoffInput>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final savedDetails = existing?.dropoffAddress.trim() ?? '';
        return DropoffDetailsSheet(
          initialName: existing?.receiverName ?? '',
          initialPhone: existing?.receiverPhone ?? '',
          lat: lat,
          lng: lng,
          address: location.fullAddress,
          initialAddressDetails:
              savedDetails.isNotEmpty ? savedDetails : location.fullAddress,
        );
      },
    );
  }

  Future<void> pickPackageImage() async {
    final file = await getIt<ImagePickerService>().pickImage(crop: true);
    if (file == null || !mounted) return;
    ref.read(packageShipmentDraftProvider.notifier).setPackageImage(file);
  }

  Future<bool> calculatePackagePrice() async {
    final draft = ref.read(packageShipmentDraftProvider);
    final size = draft.selectedSize;
    final pickup = draft.pickupAddress;
    if (size == null) {
      UIHelper.showAlert('Please select a package size'.tr, type: DialogType.warning);
      return false;
    }
    if (pickup?.latitude == null || pickup?.longitude == null) {
      UIHelper.showAlert('Please select a pickup address'.tr,
          type: DialogType.warning);
      return false;
    }
    if (draft.dropoffs.isEmpty || draft.dropoffs.any((d) => !d.isValid)) {
      UIHelper.showAlert('Please add at least one valid dropoff'.tr,
          type: DialogType.warning);
      return false;
    }

    ref.read(isLoadingProvider(calculateLoadingKey).notifier).state = true;
    try {
      final res = await getIt<CalculatePackagePriceUseCase>().call(
        CalculatePackagePriceParams(
          packageSizeId: size.id,
          pickupLat: pickup!.latitude!,
          pickupLng: pickup.longitude!,
          dropoffs: draft.dropoffs,
        ),
      );
      return await res.fold(
        (failure) async {
          UIHelper.showAlert(failure.message, type: DialogType.error);
          return false;
        },
        (quote) async {
          ref.read(packageShipmentDraftProvider.notifier).setPriceQuote(quote);
          return true;
        },
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider(calculateLoadingKey).notifier).state = false;
      }
    }
  }

  Future<void> createPackageShipment() async {
    final draft = ref.read(packageShipmentDraftProvider);
    final size = draft.selectedSize;
    final pickup = draft.pickupAddress;
    if (size == null ||
        pickup?.latitude == null ||
        pickup?.longitude == null ||
        draft.dropoffs.isEmpty) {
      return;
    }

    if (draft.priceQuote == null) {
      final ok = await calculatePackagePrice();
      if (!ok) return;
    }

    ref.read(isLoadingProvider(createLoadingKey).notifier).state = true;
    try {
      final res = await getIt<CreatePackageShipmentUseCase>().call(
        CreatePackageShipmentParams(
          packageSizeId: size.id,
          pickupLat: pickup!.latitude!,
          pickupLng: pickup.longitude!,
          paymentMethod: draft.paymentMethod.apiValue,
          dropoffs: draft.dropoffs,
          packageImage: draft.packageImage,
        ),
      );
      await res.fold(
        (failure) async {
          UIHelper.showAlert(failure.message, type: DialogType.error);
        },
        (shipment) async {
          ref.invalidate(fetchMyPackageShipmentsProvider);
          ref.read(packageShipmentDraftProvider.notifier).reset();
          UIHelper.showGlobalSnackBar(
            text: 'Package shipment created successfully'.tr,
          );
          if (!mounted) return;
          Get.off(
            () => PackageShipmentDetailsScreen(
              shipmentId: shipment.id.toString(),
            ),
          );
        },
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider(createLoadingKey).notifier).state = false;
      }
    }
  }

  Future<void> cancelPackageShipment(String shipmentId) async {
    final key = cancelLoadingKey(shipmentId);
    if (ref.read(isLoadingProvider(key))) return;
    ref.read(isLoadingProvider(key).notifier).state = true;
    try {
      final res = await getIt<CancelPackageShipmentUseCase>().call(shipmentId);
      await res.fold(
        (failure) async {
          UIHelper.showAlert(failure.message, type: DialogType.error);
        },
        (_) async {
          ref.invalidate(fetchMyPackageShipmentsProvider);
          ref.invalidate(fetchPackageShipmentDetailsProvider(shipmentId));
          UIHelper.showGlobalSnackBar(
            text: 'Package shipment cancelled successfully'.tr,
          );
        },
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider(key).notifier).state = false;
      }
    }
  }
}

class _PackageAddressPickerSheet extends ConsumerWidget {
  const _PackageAddressPickerSheet();

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
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select pickup address'.tr,
                    style: AppFont.font16W700Black,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await Get.to(() => const AddressDetailsScreen());
                    ref.invalidate(fetchAddressesProvider);
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: addressesAsync.when(
              loading: () => const PageLoadingWidget(),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (addresses) {
                if (addresses.isEmpty) {
                  return Center(child: Text('No addresses yet'.tr));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: addresses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE6E6E6)),
                      ),
                      title: Text(address.label, style: AppFont.font14W600Black),
                      subtitle: Text(
                        address.address,
                        style: AppFont.font12w400Black,
                      ),
                      onTap: () => Navigator.pop(context, address),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
