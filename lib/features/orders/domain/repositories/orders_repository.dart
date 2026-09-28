import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/models/paginated_response.dart';
import '../entities/create_refund_request_params.dart';
import '../entities/order_details_entity.dart';
import '../entities/order_entity.dart';

abstract class OrdersRepository {
  Future<Either<Failure, PaginatedResponse<OrderEntity>>> getMyOrders({
    int page = 1,
    int perPage = 20,
  });
  Future<Either<Failure, OrderDetailsEntity>> getOrderDetails(String orderId);
  Future<Either<Failure, bool>> reorderOrder(String orderId);
  Future<Either<Failure, bool>> cancelOrder(String orderId);
  Future<Either<Failure, bool>> createRefundRequest(
    CreateRefundRequestParams params,
  );
}
