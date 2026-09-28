import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/config/local_data_manager_key.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/core/service/location_service/location_provider.dart';
import 'package:heraj/core/service/location_service/location_service.dart';
import 'package:heraj/features/home/presentation/view/widgets/location_bottom_sheet.dart';
import 'package:heraj/features/location/data/models/city_model.dart';
import 'package:heraj/features/location/data/models/district_model.dart';
import 'package:heraj/features/location/domain/entities/delivery_zone_entity.dart';
import 'package:heraj/features/location/domain/use_case/fetch_cities_use_case.dart';
import 'package:heraj/features/location/domain/use_case/fetch_delivery_zones_use_case.dart';
import 'package:heraj/features/location/domain/use_case/fetch_districts_use_case.dart';
import 'package:heraj/features/location/domain/use_case/fetch_neighborhoods_use_case.dart';
import 'package:heraj/main.dart';
import 'package:location/location.dart';

final fetchCitiesProvider =
    FutureProvider.autoDispose<CitiesResponse>((ref) async {
  final useCase = getIt<FetchCitiesUseCase>();
  final result = await useCase.call();
  return result.fold((l) => throw l, (r) => r);
});

final fetchDistrictsProvider = FutureProvider.autoDispose
    .family<DistrictsResponse, String>((ref, cityCode) async {
  final useCase = getIt<FetchDistrictsUseCase>();
  final result = await useCase.call(FetchDistrictsParams(cityCode));
  return result.fold((l) => throw l, (r) => r);
});

final fetchNeighborhoodsProvider = FutureProvider.autoDispose
    .family<NeighborhoodsResponse, FetchNeighborhoodsParams>((ref, params) async {
  final useCase = getIt<FetchNeighborhoodsUseCase>();
  final result = await useCase.call(params);
  return result.fold((l) => throw l, (r) => r);
});

final fetchDeliveryZonesProvider =
    FutureProvider.autoDispose<List<DeliveryZoneEntity>>((ref) async {
  final result = await getIt<FetchDeliveryZonesUseCase>().call();
  return result.fold((l) => throw l, (r) => r);
});

/// True when location service is on and permission is granted (no prompt).
final locationAccessGrantedProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  try {
    final location = Location();
    final serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) return false;
    final permission = await location.hasPermission();
    return permission == PermissionStatus.granted ||
        permission == PermissionStatus.grantedLimited;
  } catch (_) {
    return false;
  }
});

final selectedDeliveryZoneProvider =
    StateNotifierProvider<SelectedDeliveryZoneNotifier, DeliveryZoneEntity?>(
  (ref) => SelectedDeliveryZoneNotifier(),
);

class SelectedDeliveryZoneNotifier extends StateNotifier<DeliveryZoneEntity?> {
  SelectedDeliveryZoneNotifier() : super(_readPersistedZone());

  static DeliveryZoneEntity? _readPersistedZone() {
    final rawId =
        dataManager.getValue(LocalDataManagerKeys.selectedDeliveryZoneId);
    final id = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;
    final name = dataManager
            .getValue<String>(LocalDataManagerKeys.selectedDeliveryZoneName) ??
        '';
    if (id <= 0 || name.trim().isEmpty) return null;
    return DeliveryZoneEntity(
      id: id,
      name: name,
      centerLatitude: 0,
      centerLongitude: 0,
    );
  }

  Future<void> select(DeliveryZoneEntity zone) async {
    state = zone;
    await dataManager.setValue(
      LocalDataManagerKeys.selectedDeliveryZoneId,
      zone.id,
    );
    await dataManager.setValue(
      LocalDataManagerKeys.selectedDeliveryZoneName,
      zone.name,
    );
  }

  Future<void> clear() async {
    state = null;
    await dataManager.deleteValue(LocalDataManagerKeys.selectedDeliveryZoneId);
    await dataManager.deleteValue(LocalDataManagerKeys.selectedDeliveryZoneName);
  }
}

class VendorsGeoParams {
  const VendorsGeoParams({
    this.latitude,
    this.longitude,
    this.zoneId,
  });

  final double? latitude;
  final double? longitude;
  final int? zoneId;

  bool get hasCoordinates => latitude != null && longitude != null;
  bool get hasZone => zoneId != null && zoneId! > 0;

  @override
  bool operator ==(Object other) {
    return other is VendorsGeoParams &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.zoneId == zoneId;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude, zoneId);
}

/// Location-enabled → lat/lng; denied/disabled → selected zone_id.
final vendorsGeoParamsProvider = Provider.autoDispose<VendorsGeoParams>((ref) {
  final hasAccess =
      ref.watch(locationAccessGrantedProvider).valueOrNull ?? false;
  final selectedLocation = ref.watch(currentDisplayLocationProvider);
  final gpsLocation = ref.watch(fetchLocationDetailsProvider).valueOrNull;
  final zone = ref.watch(selectedDeliveryZoneProvider);

  if (hasAccess) {
    final LocationDetails? details = selectedLocation ?? gpsLocation;
    if (details != null) {
      return VendorsGeoParams(
        latitude: details.latitude,
        longitude: details.longitude,
      );
    }
  }

  if (zone != null && zone.id > 0) {
    return VendorsGeoParams(zoneId: zone.id);
  }

  return const VendorsGeoParams();
});
