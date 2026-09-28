import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/order_details_entity.dart';
import '../repositories/orders_repository.dart';

class GetOrderDetailsUseCase {
  final OrdersRepository repository;

  const GetOrderDetailsUseCase({required this.repository});

  Future<Either<Failure, OrderDetailsEntity>> call(String orderId) {
    return repository.getOrderDetails(orderId);
  }
}

