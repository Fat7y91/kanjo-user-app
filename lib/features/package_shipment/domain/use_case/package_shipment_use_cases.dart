import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/package_price_quote_entity.dart';
import '../entities/package_shipment_entity.dart';
import '../entities/package_shipment_params.dart';
import '../entities/package_size_entity.dart';
import '../repo/package_shipment_repo.dart';

class FetchPackageSizesUseCase
    extends UseCaseNoParam<List<PackageSizeEntity>> {
  FetchPackageSizesUseCase({required this.repo});

  final PackageShipmentRepo repo;

  @override
  Future<Either<Failure, List<PackageSizeEntity>>> call() {
    return repo.getPackageSizes();
  }
}

class CalculatePackagePriceUseCase
    extends UseCaseParam<PackagePriceQuoteEntity, CalculatePackagePriceParams> {
  CalculatePackagePriceUseCase({required this.repo});

  final PackageShipmentRepo repo;

  @override
  Future<Either<Failure, PackagePriceQuoteEntity>> call(
    CalculatePackagePriceParams params,
  ) {
    return repo.calculatePrice(params);
  }
}

class CreatePackageShipmentUseCase
    extends UseCaseParam<PackageShipmentEntity, CreatePackageShipmentParams> {
  CreatePackageShipmentUseCase({required this.repo});

  final PackageShipmentRepo repo;

  @override
  Future<Either<Failure, PackageShipmentEntity>> call(
    CreatePackageShipmentParams params,
  ) {
    return repo.createShipment(params);
  }
}

class FetchPackageShipmentDetailsUseCase
    extends UseCaseParam<PackageShipmentEntity, String> {
  FetchPackageShipmentDetailsUseCase({required this.repo});

  final PackageShipmentRepo repo;

  @override
  Future<Either<Failure, PackageShipmentEntity>> call(String shipmentId) {
    return repo.getShipmentDetails(shipmentId);
  }
}

class FetchMyPackageShipmentsUseCase extends UseCaseParam<
    PaginatedResponse<PackageShipmentEntity>, ({int page, int perPage})> {
  FetchMyPackageShipmentsUseCase({required this.repo});

  final PackageShipmentRepo repo;

  @override
  Future<Either<Failure, PaginatedResponse<PackageShipmentEntity>>> call(
    ({int page, int perPage}) params,
  ) {
    return repo.getMyShipments(page: params.page, perPage: params.perPage);
  }
}

class CancelPackageShipmentUseCase extends UseCaseParam<bool, String> {
  CancelPackageShipmentUseCase({required this.repo});

  final PackageShipmentRepo repo;

  @override
  Future<Either<Failure, bool>> call(String shipmentId) {
    return repo.cancelShipment(shipmentId);
  }
}
