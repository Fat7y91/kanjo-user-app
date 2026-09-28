import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/models/paginated_response.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class GetMyOrdersUseCase {
  final OrdersRepository repository;

  const GetMyOrdersUseCase({required this.repository});

  Future<Either<Failure, PaginatedResponse<OrderEntity>>> call({
    int page = 1,
    int perPage = 20,
  }) {
    return repository.getMyOrders(page: page, perPage: perPage);
  }
}
