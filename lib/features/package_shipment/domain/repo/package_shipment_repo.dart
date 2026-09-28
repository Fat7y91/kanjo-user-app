import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/models/paginated_response.dart';
import '../entities/package_price_quote_entity.dart';
import '../entities/package_shipment_entity.dart';
import '../entities/package_shipment_params.dart';
import '../entities/package_size_entity.dart';

abstract class PackageShipmentRepo {
  Future<Either<Failure, List<PackageSizeEntity>>> getPackageSizes();

  Future<Either<Failure, PackagePriceQuoteEntity>> calculatePrice(
    CalculatePackagePriceParams params,
  );

  Future<Either<Failure, PackageShipmentEntity>> createShipment(
    CreatePackageShipmentParams params,
  );

  Future<Either<Failure, PackageShipmentEntity>> getShipmentDetails(
    String shipmentId,
  );

  Future<Either<Failure, PaginatedResponse<PackageShipmentEntity>>>
      getMyShipments({
    int page = 1,
    int perPage = 15,
  });

  Future<Either<Failure, bool>> cancelShipment(String shipmentId);
}
