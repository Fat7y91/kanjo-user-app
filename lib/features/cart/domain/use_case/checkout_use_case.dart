import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/checkout_params.dart';
import '../repo/cart_repo.dart';

class CheckoutUseCase extends UseCaseParam<CheckoutResult, CheckoutParams> {
  CheckoutUseCase({required this.cartRepo});

  final CartRepo cartRepo;

  @override
  Future<Either<Failure, CheckoutResult>> call(CheckoutParams param) {
    return cartRepo.checkout(param);
  }
}
