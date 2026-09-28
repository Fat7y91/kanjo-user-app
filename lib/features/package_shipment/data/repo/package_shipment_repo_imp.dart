import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/package_price_quote_entity.dart';
import '../../domain/entities/package_shipment_entity.dart';
import '../../domain/entities/package_shipment_params.dart';
import '../../domain/entities/package_size_entity.dart';
import '../../domain/repo/package_shipment_repo.dart';
import '../data_source/package_shipment_data_source.dart';

class PackageShipmentRepoImp extends PackageShipmentRepo {
  PackageShipmentRepoImp({required this.dataSource});

  final PackageShipmentDataSource dataSource;

  @override
  Future<Either<Failure, List<PackageSizeEntity>>> getPackageSizes() async {
    try {
      return Right(await dataSource.getPackageSizes());
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioError(e));
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, PackagePriceQuoteEntity>> calculatePrice(
    CalculatePackagePriceParams params,
  ) async {
    try {
      return Right(await dataSource.calculatePrice(params));
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioError(e));
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, PackageShipmentEntity>> createShipment(
    CreatePackageShipmentParams params,
  ) async {
    try {
      return Right(await dataSource.createShipment(params));
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioError(e));
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, PackageShipmentEntity>> getShipmentDetails(
    String shipmentId,
  ) async {
    try {
      return Right(await dataSource.getShipmentDetails(shipmentId));
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioError(e));
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, PaginatedResponse<PackageShipmentEntity>>>
      getMyShipments({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      return Right(
        await dataSource.getMyShipments(page: page, perPage: perPage),
      );
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioError(e));
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelShipment(String shipmentId) async {
    try {
      return Right(await dataSource.cancelShipment(shipmentId));
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioError(e));
      return Left(GeneralError(e));
    }
  }
}
