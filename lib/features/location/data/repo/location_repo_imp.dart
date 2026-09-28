import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';
import 'package:heraj/features/location/data/data_source/location_data_source.dart';
import 'package:heraj/features/location/data/models/city_model.dart';
import 'package:heraj/features/location/data/models/district_model.dart';
import 'package:heraj/features/location/domain/entities/delivery_zone_entity.dart';
import 'package:heraj/features/location/domain/repo/location_repo.dart';

class LocationRepoImp implements LocationRepo {
  final LocationDataSource locationDataSource;

  LocationRepoImp({required this.locationDataSource});

  @override
  Future<Either<Failure, CitiesResponse>> getCities() async {
    try {
      final cities = await locationDataSource.getCities();
      return Right(cities);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, DistrictsResponse>> getDistricts(
      String cityCode) async {
    try {
      final districts = await locationDataSource.getDistricts(cityCode);
      return Right(districts);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, NeighborhoodsResponse>> getNeighborhoods(
      String cityCode, String districtName) async {
    try {
      final neighborhoods =
          await locationDataSource.getNeighborhoods(cityCode, districtName);
      return Right(neighborhoods);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, List<DeliveryZoneEntity>>> getDeliveryZones() async {
    try {
      final zones = await locationDataSource.getDeliveryZones();
      return Right(zones);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }
}
