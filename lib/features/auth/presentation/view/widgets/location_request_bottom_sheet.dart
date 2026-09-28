import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/location_service/location_provider.dart';
import 'package:heraj/core/service/location_service/location_service.dart';
import 'package:heraj/features/home/presentation/managers/home_vendors_provider.dart';
import 'package:heraj/features/home/presentation/view/widgets/location_bottom_sheet.dart';
import 'package:heraj/features/location/presentation/managers/location_provider.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:location/location.dart';

Future<LocationDetails?> showLocationRequestBottomSheet({
  BuildContext? context,
}) async {
  return await showModalBottomSheet<LocationDetails?>(
    context: Get.context ?? context!,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const LocationRequestBottomSheet(),
  );
}

class LocationRequestBottomSheet extends ConsumerStatefulWidget {
  const LocationRequestBottomSheet({super.key});

  @override
  ConsumerState<LocationRequestBottomSheet> createState() =>
      _LocationRequestBottomSheetState();
}

class _LocationRequestBottomSheetState
    extends ConsumerState<LocationRequestBottomSheet> {
  bool _isLoadingLocation = false;

  Future<void> _requestCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      final locationService = getIt<LocationService>();
      final location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          if (mounted) Navigator.pop(context, null);
          return;
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted &&
            permissionGranted != PermissionStatus.grantedLimited) {
          if (mounted) Navigator.pop(context, null);
          return;
        }
      }

      final locationDetails = await locationService.getCurrentLocation();

      if (locationDetails != null) {
        ref.read(currentDisplayLocationProvider.notifier).state =
            locationDetails;
        await ref.read(selectedDeliveryZoneProvider.notifier).clear();
        ref.invalidate(fetchLocationDetailsProvider);
        ref.invalidate(locationAccessGrantedProvider);
        ref.invalidate(homeVendorsProvider);

        if (mounted) {
          Navigator.pop(context, locationDetails);
        }
      } else if (mounted) {
        Navigator.pop(context, null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColor.danger,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  void _skipLocationSelection() {
    if (!mounted) return;
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: size.height * 0.55,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.asset(
                    AppAssets.location,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return ColoredBox(
                        color: AppColor.grey1.withAlpha(50),
                        child: Icon(
                          Icons.map_outlined,
                          size: 100,
                          color: AppColor.grey2,
                        ),
                      );
                    },
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00FFFFFF),
                        Color(0xE6FFFFFF),
                      ],
                      stops: [0.0, 0.8],
                    ),
                  ),
                ),
                Center(
                  child: Image.asset(
                    AppAssets.locationPointer,
                    height: 100,
                    width: 100,
                  ),
                ),
                PositionedDirectional(
                  top: 16,
                  end: 16,
                  child: GestureDetector(
                    onTap: _isLoadingLocation ? null : _skipLocationSelection,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: AppColor.grey2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 10 + bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'We need to access your location'.tr,
                    style: AppFont.font18W700Black.copyWith(
                      color: AppColor.primary,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Gap(10),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: CustomFilledButton(
                    isLoading: _isLoadingLocation,
                    onPressed:
                        _isLoadingLocation ? null : _requestCurrentLocation,
                    text: 'Allow Location Access'.tr,
                  ),
                ),
                const Gap(16),
                TextButton(
                  onPressed: _isLoadingLocation ? null : _skipLocationSelection,
                  child: Text(
                    "Don't Allow".tr,
                    style: AppFont.font14W600Grey2,
                  ),
                ),
                const Gap(10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColor.grey2,
                    borderRadius: BorderRadius.circular(2),
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
