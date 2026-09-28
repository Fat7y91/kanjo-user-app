import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../../../config/api_path.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../../domain/entities/create_refund_request_params.dart';
import '../../domain/entities/order_details_entity.dart';
import '../../domain/entities/order_entity.dart';
import 'orders_data_source.dart';

class OrdersDataSourceImpl implements OrdersDataSource {
  final ApiService apiService;

  OrdersDataSourceImpl({required this.apiService});

  @override
  Future<PaginatedResponse<OrderEntity>> getMyOrders({
    int page = 1,
    int perPage = 20,
  }) async {
    final res = await apiService.get(
      url: ApiPath.getOrdersList(page: page, perPage: perPage),
      returnDataOnly: false,
    );

    return parsePaginatedResponse(
      res,
      (json) => OrderEntity.fromJson(json),
    );
  }

  @override
  Future<OrderDetailsEntity> getOrderDetails(String orderId) async {
    final res = await apiService.get(
      url: '${ApiPath.getOrders}/$orderId',
      returnDataOnly: true,
    );

    final json = res is Map
        ? Map<String, dynamic>.from(res)
        : <String, dynamic>{};

    return OrderDetailsEntity.fromJson(json);
  }

  @override
  Future<bool> reorderOrder(String orderId) async {
    await apiService.post(
      url: ApiPath.reorderOrder(orderId),
      returnDataOnly: true,
    );
    return true;
  }

  @override
  Future<bool> cancelOrder(String orderId) async {
    await apiService.post(
      url: ApiPath.cancelOrder(orderId),
      returnDataOnly: true,
    );
    return true;
  }

  @override
  Future<bool> createRefundRequest(CreateRefundRequestParams params) async {
    final map = <String, dynamic>{
      'reason': params.reason.trim(),
    };
    for (var i = 0; i < params.images.length; i++) {
      final file = params.images[i];
      map['images[$i]'] = await MultipartFile.fromFile(
        file.path,
        filename: p.basename(file.path),
      );
    }

    await apiService.post(
      url: ApiPath.orderRefundRequests(params.orderId),
      requestBody: FormData.fromMap(map),
      returnDataOnly: true,
    );
    return true;
  }
}
