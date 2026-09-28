import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../repositories/orders_repository.dart';

class ReorderOrderUseCase extends UseCaseParam<bool, String> {
  final OrdersRepository repository;

  ReorderOrderUseCase({required this.repository});

  @override
  Future<Either<Failure, bool>> call(String orderId) {
    return repository.reorderOrder(orderId);
  }
}
