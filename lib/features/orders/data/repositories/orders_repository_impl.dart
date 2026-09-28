import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/create_refund_request_params.dart';
import '../../domain/entities/order_details_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../data_sources/orders_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersDataSource dataSource;

  const OrdersRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, PaginatedResponse<OrderEntity>>> getMyOrders({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final res = await dataSource.getMyOrders(page: page, perPage: perPage);
      return right(res);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, OrderDetailsEntity>> getOrderDetails(
    String orderId,
  ) async {
    try {
      final res = await dataSource.getOrderDetails(orderId);
      return right(res);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, bool>> reorderOrder(String orderId) async {
    try {
      final res = await dataSource.reorderOrder(orderId);
      return right(res);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelOrder(String orderId) async {
    try {
      final res = await dataSource.cancelOrder(orderId);
      return right(res);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, bool>> createRefundRequest(
    CreateRefundRequestParams params,
  ) async {
    try {
      final res = await dataSource.createRefundRequest(params);
      return right(res);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(GeneralError(e));
    }
  }
}
