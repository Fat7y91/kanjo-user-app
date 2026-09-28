import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../repo/cart_repo.dart';

class RemoveCartItemUseCase extends UseCaseParam<bool, int> {
  final CartRepo cartRepo;

  RemoveCartItemUseCase({required this.cartRepo});

  @override
  Future<Either<Failure, bool>> call(int param) {
    return cartRepo.removeFromCart(param);
  }
}
