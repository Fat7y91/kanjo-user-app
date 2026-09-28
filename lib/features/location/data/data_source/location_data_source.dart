import 'package:heraj/config/api_path.dart';
import 'package:heraj/core/service/webservice/dio_helper.dart';
import 'package:heraj/features/location/data/models/city_model.dart';
import 'package:heraj/features/location/data/models/district_model.dart';
import 'package:heraj/features/location/domain/entities/delivery_zone_entity.dart';

abstract class LocationDataSource {
  Future<CitiesResponse> getCities();
  Future<DistrictsResponse> getDistricts(String cityCode);
  Future<NeighborhoodsResponse> getNeighborhoods(
      String cityCode, String districtName);
  Future<List<DeliveryZoneEntity>> getDeliveryZones();
}

class LocationDataSourceImpl implements LocationDataSource {
  final ApiService apiService;

  LocationDataSourceImpl({required this.apiService});

  @override
  Future<CitiesResponse> getCities() async {
    final res =
        await apiService.get(url: ApiPath.getCities, returnDataOnly: true);
    return CitiesResponse.fromJson(res);
  }

  @override
  Future<DistrictsResponse> getDistricts(String cityCode) async {
    final res = await apiService.get(
      url: ApiPath.getDistricts(cityCode),
      returnDataOnly: true,
    );
    return DistrictsResponse.fromJson(res);
  }

  @override
  Future<NeighborhoodsResponse> getNeighborhoods(
    String cityCode,
    String districtName,
  ) async {
    final res = await apiService.get(
      url: ApiPath.getNeighborhoods(cityCode, districtName),
      returnDataOnly: true,
    );
    return NeighborhoodsResponse.fromJson(res);
  }

  @override
  Future<List<DeliveryZoneEntity>> getDeliveryZones() async {
    final res = await apiService.get(
      url: ApiPath.getDeliveryZones,
      returnDataOnly: true,
    );
    final list = res is List ? res : <dynamic>[];
    return list
        .whereType<Map>()
        .map((e) => DeliveryZoneEntity.fromJson(Map<String, dynamic>.from(e)))
        .where((zone) => zone.id > 0)
        .toList();
  }
}
