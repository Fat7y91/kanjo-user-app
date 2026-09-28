import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';
import 'package:heraj/features/location/data/models/city_model.dart';
import 'package:heraj/features/location/data/models/district_model.dart';
import 'package:heraj/features/location/domain/entities/delivery_zone_entity.dart';

abstract class LocationRepo {
  Future<Either<Failure, CitiesResponse>> getCities();
  Future<Either<Failure, DistrictsResponse>> getDistricts(String cityCode);
  Future<Either<Failure, NeighborhoodsResponse>> getNeighborhoods(
      String cityCode, String districtName);
  Future<Either<Failure, List<DeliveryZoneEntity>>> getDeliveryZones();
}
