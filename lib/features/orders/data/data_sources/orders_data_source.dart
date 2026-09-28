import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/create_refund_request_params.dart';
import '../../domain/entities/order_details_entity.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrdersDataSource {
  Future<PaginatedResponse<OrderEntity>> getMyOrders({
    int page = 1,
    int perPage = 20,
  });
  Future<OrderDetailsEntity> getOrderDetails(String orderId);
  Future<bool> reorderOrder(String orderId);
  Future<bool> cancelOrder(String orderId);
  Future<bool> createRefundRequest(CreateRefundRequestParams params);
}
