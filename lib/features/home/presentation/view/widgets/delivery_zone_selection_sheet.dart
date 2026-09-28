import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/location_service/location_provider.dart';
import 'package:heraj/core/service/location_service/location_service.dart';
import 'package:heraj/features/home/presentation/managers/home_vendors_provider.dart';
import 'package:heraj/features/home/presentation/view/widgets/location_bottom_sheet.dart';
import 'package:heraj/features/location/domain/entities/delivery_zone_entity.dart';
import 'package:heraj/features/location/presentation/managers/location_provider.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';
import 'package:heraj/ui/ui.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

Future<DeliveryZoneEntity?> showDeliveryZoneBottomSheet({
  BuildContext? context,
}) async {
  return showModalBottomSheet<DeliveryZoneEntity?>(
    context: Get.context ?? context!,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const DeliveryZoneSelectionSheet(),
  );
}

class DeliveryZoneSelectionSheet extends ConsumerStatefulWidget {
  const DeliveryZoneSelectionSheet({super.key});

  @override
  ConsumerState<DeliveryZoneSelectionSheet> createState() =>
      _DeliveryZoneSelectionSheetState();
}

class _DeliveryZoneSelectionSheetState
    extends ConsumerState<DeliveryZoneSelectionSheet>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  final ValueNotifier<bool> _isRequestingLocation = ValueNotifier<bool>(false);
  var _awaitingSettingsReturn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _searchQuery.dispose();
    _isRequestingLocation.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingSettingsReturn) {
      _awaitingSettingsReturn = false;
      _requestCurrentLocation(fromSettingsReturn: true);
    }
  }

  Future<void> _onSelectZone(DeliveryZoneEntity zone) async {
    await ref.read(selectedDeliveryZoneProvider.notifier).select(zone);
    ref.read(currentDisplayLocationProvider.notifier).state = null;
    ref.invalidate(homeVendorsProvider);
    if (mounted) {
      Navigator.pop(context, zone);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    UIHelper.showGlobalSnackBar(text: message);
  }

  Future<void> _requestCurrentLocation({
    bool fromSettingsReturn = false,
  }) async {
    if (_isRequestingLocation.value) return;
    _isRequestingLocation.value = true;
    try {
      final location = Location();

      var serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          _showMessage('Location services are disabled'.tr);
          return;
        }
      }

      var status = await ph.Permission.location.status;
      if (!status.isGranted) {
        status = await ph.Permission.location.request();
      }

      if (status.isPermanentlyDenied || status.isRestricted) {
        if (fromSettingsReturn) {
          _showMessage(
            'Enable location permission in settings, then try again'.tr,
          );
          return;
        }
        _awaitingSettingsReturn = true;
        _showMessage(
          'Enable location permission in settings, then try again'.tr,
        );
        await ph.openAppSettings();
        return;
      }

      if (!status.isGranted && !status.isLimited) {
        _showMessage('Location permission denied'.tr);
        return;
      }

      final pluginPermission = await location.hasPermission();
      if (pluginPermission != PermissionStatus.granted &&
          pluginPermission != PermissionStatus.grantedLimited) {
        await location.requestPermission();
      }

      final details = await getIt<LocationService>()
          .getCurrentLocation()
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () => null,
          );
      if (!mounted) return;
      if (details == null) {
        _showMessage('Unable to get current location'.tr);
        return;
      }

      ref.read(currentDisplayLocationProvider.notifier).state = details;
      await ref.read(selectedDeliveryZoneProvider.notifier).clear();
      ref.invalidate(fetchLocationDetailsProvider);
      ref.invalidate(locationAccessGrantedProvider);
      ref.invalidate(homeVendorsProvider);
      if (mounted) Navigator.pop(context, null);
    } catch (_) {
      _showMessage('Unable to get current location'.tr);
    } finally {
      if (mounted) _isRequestingLocation.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final zonesAsync = ref.watch(fetchDeliveryZonesProvider);
    final selected = ref.watch(selectedDeliveryZoneProvider);
    final size = MediaQuery.sizeOf(context);

    return Container(
      height: size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Select zone'.tr,
                  style: AppFont.font18W700Black,
                ),
                const Spacer(),
                ValueListenableBuilder<bool>(
                  valueListenable: _isRequestingLocation,
                  builder: (context, isLoading, _) {
                    return IconButton(
                      tooltip: 'Use current location'.tr,
                      onPressed: isLoading ? null : _requestCurrentLocation,
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: LoadingWidget(size: 20),
                            )
                          : const Icon(
                              Icons.my_location_rounded,
                              color: AppColor.primary,
                            ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColor.primary.withAlpha(26),
                        padding: const EdgeInsets.all(8),
                      ),
                    );
                  },
                ),
                const Gap(4),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColor.grey1.withAlpha(125),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _searchQuery.value = value.toLowerCase(),
              decoration: InputDecoration(
                hintText: 'Search zone...'.tr,
                hintStyle: AppFont.font14W500Grey2,
                prefixIcon: Icon(Icons.search, color: AppColor.grey2),
                filled: true,
                fillColor: AppColor.grey1.withAlpha(75),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: zonesAsync.customWhen(
              ref: ref,
              refreshable: fetchDeliveryZonesProvider.future,
              loading: () => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: 6,
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ShimmerEffect(
                    enable: true,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECECEC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              error: (_, __) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: AppColor.danger),
                    const Gap(16),
                    Text(
                      'Failed to load zones'.tr,
                      style: AppFont.font14W500Grey2,
                    ),
                  ],
                ),
              ),
              data: (zones) {
                if (zones.isEmpty) {
                  return Center(
                    child: Text(
                      'No zones found'.tr,
                      style: AppFont.font14W500Grey2,
                    ),
                  );
                }
                return ValueListenableBuilder<String>(
                  valueListenable: _searchQuery,
                  builder: (context, query, _) {
                    final filtered = query.isEmpty
                        ? zones
                        : zones
                            .where(
                              (z) => z.name.toLowerCase().contains(query),
                            )
                            .toList();
                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          'No zones found'.tr,
                          style: AppFont.font14W500Grey2,
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final zone = filtered[index];
                        final isSelected = selected?.id == zone.id;
                        return InkWell(
                          onTap: () => _onSelectZone(zone),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColor.primary.withAlpha(25)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColor.primary
                                        : AppColor.grey1.withAlpha(125),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.map_outlined,
                                    size: 20,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColor.grey2,
                                  ),
                                ),
                                const Gap(12),
                                Expanded(
                                  child: Text(
                                    zone.name,
                                    style: isSelected
                                        ? AppFont.font16W700Black.copyWith(
                                            color: AppColor.primary,
                                          )
                                        : AppFont.font15W500Black,
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColor.primary,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
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
