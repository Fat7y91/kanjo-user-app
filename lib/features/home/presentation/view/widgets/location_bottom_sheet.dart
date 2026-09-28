import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/location_service/location_service.dart';
import 'package:heraj/core/service/location_service/location_provider.dart';
import 'package:heraj/features/home/presentation/managers/home_vendors_provider.dart';
import 'package:heraj/features/location/data/models/city_model.dart';
import 'package:heraj/features/location/presentation/managers/location_provider.dart';
import 'package:heraj/main.dart';
import 'package:location/location.dart';
import 'package:get/get.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';

final selectedCityProvider = StateProvider.autoDispose<CityModel?>((ref) => null);

final currentDisplayLocationProvider = StateProvider<LocationDetails?>((ref) => null);

Future<LocationDetails?> showLocationBottomSheet({BuildContext? context}) async {
  return await showModalBottomSheet<LocationDetails?>(
    context: Get.context ?? context!,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const CitySelectionSheet(),
  );
}

class CitySelectionSheet extends ConsumerStatefulWidget {
  const CitySelectionSheet({super.key});

  @override
  ConsumerState<CitySelectionSheet> createState() => _CitySelectionSheetState();
}

class _CitySelectionSheetState extends ConsumerState<CitySelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoadingLocation = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(fetchCitiesProvider);
    final size = MediaQuery.of(context).size;
    final locale = Get.locale?.languageCode ?? 'en';

    return Container(
      height: size.height * 0.75,
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
                  'Select City'.tr,
                  style: AppFont.font18W700Black,
                ),
                const Spacer(),
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
          const Gap(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search city...'.tr,
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
          const Gap(16),
          Expanded(
            child: citiesAsync.when(
              data: (citiesResponse) {
                final cities = citiesResponse.cities;
                final filteredCities = _searchQuery.isEmpty
                    ? cities
                    : cities.where((city) {
                        final name =
                            city.getLocalizedName(locale).toLowerCase();
                        return name.contains(_searchQuery);
                      }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: filteredCities.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildCityItem(
                        context: context,
                        icon: Icons.location_on,
                        name: 'All Turkey'.tr,
                        isAllCountry: true,
                        onTap: () async {
                          await _requestCurrentLocation(context);
                        },
                      );
                    }

                    final city = filteredCities[index - 1];
                    return _buildCityItem(
                      context: context,
                      icon: Icons.location_city,
                      name: city.getLocalizedName(locale),
                      onTap: () async {
                        ref.read(selectedCityProvider.notifier).state = city;

                        final gpsLocation =
                            await ref.read(fetchLocationDetailsProvider.future);

                        final locationDetails = LocationDetails(
                          latitude: gpsLocation?.latitude ?? 0,
                          longitude: gpsLocation?.longitude ?? 0,
                          name: city.getLocalizedName(locale),
                          fullAddress: gpsLocation?.fullAddress ??
                              city.getLocalizedName(locale),
                        );
                        ref
                            .read(currentDisplayLocationProvider.notifier)
                            .state = locationDetails;
                        if (context.mounted) {
                          Navigator.pop(context, locationDetails);
                        }
                      },
                    );
                  },
                );
              },
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
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: AppColor.danger),
                    const Gap(16),
                    Text(
                      'Failed to load cities'.tr,
                      style: AppFont.font14W500Grey2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityItem({
    required BuildContext context,
    required IconData icon,
    required String name,
    bool isAllCountry = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isLoadingLocation ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isAllCountry
              ? AppColor.primary.withAlpha(25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isAllCountry
                    ? AppColor.primary
                    : AppColor.grey1.withAlpha(125),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isAllCountry ? Colors.white : AppColor.grey2,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Text(
                name,
                style: isAllCountry
                    ? AppFont.font16W700Black.copyWith(color: AppColor.primary)
                    : AppFont.font15W500Black,
              ),
            ),
            if (_isLoadingLocation && isAllCountry)
              const SizedBox(
                width: 20,
                height: 20,
                child: LoadingWidget(size: 20),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestCurrentLocation(BuildContext context) async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      Location location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          if (mounted) Navigator.pop(context, null);
          return;
        }
      }

      PermissionStatus permission = await location.hasPermission();

      if (permission == PermissionStatus.denied) {
        permission = await location.requestPermission();
        if (permission != PermissionStatus.granted &&
            permission != PermissionStatus.grantedLimited) {
          if (mounted) Navigator.pop(context, null);
          return;
        }
      }

      if (permission == PermissionStatus.deniedForever) {
        if (mounted) Navigator.pop(context, null);
        return;
      }

      if (permission != PermissionStatus.granted &&
          permission != PermissionStatus.grantedLimited) {
        if (mounted) Navigator.pop(context, null);
        return;
      }

      final details = await getIt<LocationService>().getCurrentLocation();
      if (mounted) {
        ref.read(currentDisplayLocationProvider.notifier).state = details;
        await ref.read(selectedDeliveryZoneProvider.notifier).clear();
        ref.invalidate(locationAccessGrantedProvider);
        ref.invalidate(homeVendorsProvider);
        Navigator.pop(context, details);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }
}
