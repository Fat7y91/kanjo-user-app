import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/create_refund_request_params.dart';
import '../repositories/orders_repository.dart';

class CreateRefundRequestUseCase
    extends UseCaseParam<bool, CreateRefundRequestParams> {
  final OrdersRepository repository;

  CreateRefundRequestUseCase({required this.repository});

  @override
  Future<Either<Failure, bool>> call(CreateRefundRequestParams params) {
    return repository.createRefundRequest(params);
  }
}
