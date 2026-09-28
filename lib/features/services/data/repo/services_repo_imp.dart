import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/models/paginated_response.dart';
import '../../domain/entities/create_service_order_params.dart';
import '../../domain/entities/provider_service_entity.dart';
import '../../domain/entities/service_order_entity.dart';
import '../../domain/entities/service_type_entity.dart';
import '../../domain/repo/services_repo.dart';
import '../data_source/services_data_source.dart';

class ServicesRepoImp extends ServicesRepo {
  ServicesRepoImp({required this.dataSource});

  final ServicesDataSource dataSource;

  Either<Failure, T> _catchError<T>(Object e) {
    if (e is DioException) return Left(ServerFailure.fromDioError(e));
    return Left(GeneralError(e));
  }

  @override
  Future<Either<Failure, List<ServiceTypeEntity>>> getServiceTypes() async {
    try {
      return Right(await dataSource.getServiceTypes());
    } catch (e) {
      return _catchError(e);
    }
  }

  @override
  Future<Either<Failure, List<ProviderServiceEntity>>> getProviderServices({
    int? serviceTypeId,
    int? serviceProviderId,
  }) async {
    try {
      return Right(
        await dataSource.getProviderServices(
          serviceTypeId: serviceTypeId,
          serviceProviderId: serviceProviderId,
        ),
      );
    } catch (e) {
      return _catchError(e);
    }
  }

  @override
  Future<Either<Failure, List<ServiceProviderEntity>>> getServiceProviders({
    int? serviceTypeId,
    String? search,
  }) async {
    try {
      return Right(
        await dataSource.getServiceProviders(
          serviceTypeId: serviceTypeId,
          search: search,
        ),
      );
    } catch (e) {
      return _catchError(e);
    }
  }

  @override
  Future<Either<Failure, ServiceProviderEntity>> getServiceProvider(
    int serviceProviderId,
  ) async {
    try {
      return Right(await dataSource.getServiceProvider(serviceProviderId));
    } catch (e) {
      return _catchError(e);
    }
  }

  @override
  Future<Either<Failure, bool>> createServiceOrder(
    CreateServiceOrderParams params,
  ) async {
    try {
      return Right(await dataSource.createServiceOrder(params));
    } catch (e) {
      return _catchError(e);
    }
  }

  @override
  Future<Either<Failure, PaginatedResponse<ServiceOrderEntity>>>
      getMyServiceOrders({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      return Right(
        await dataSource.getMyServiceOrders(page: page, perPage: perPage),
      );
    } catch (e) {
      return _catchError(e);
    }
  }
}
