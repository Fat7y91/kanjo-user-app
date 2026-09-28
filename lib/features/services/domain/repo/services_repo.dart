import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/models/paginated_response.dart';
import '../entities/create_service_order_params.dart';
import '../entities/provider_service_entity.dart';
import '../entities/service_order_entity.dart';
import '../entities/service_type_entity.dart';

abstract class ServicesRepo {
  Future<Either<Failure, List<ServiceTypeEntity>>> getServiceTypes();

  Future<Either<Failure, List<ProviderServiceEntity>>> getProviderServices({
    int? serviceTypeId,
    int? serviceProviderId,
  });

  Future<Either<Failure, List<ServiceProviderEntity>>> getServiceProviders({
    int? serviceTypeId,
    String? search,
  });

  Future<Either<Failure, ServiceProviderEntity>> getServiceProvider(
    int serviceProviderId,
  );

  Future<Either<Failure, bool>> createServiceOrder(
    CreateServiceOrderParams params,
  );

  Future<Either<Failure, PaginatedResponse<ServiceOrderEntity>>>
      getMyServiceOrders({
    int page = 1,
    int perPage = 20,
  });
}
