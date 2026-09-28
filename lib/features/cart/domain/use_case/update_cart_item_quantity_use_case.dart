import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../repo/cart_repo.dart';

class UpdateCartItemQuantityParams {
  final int cartItemId;
  final int quantity;

  const UpdateCartItemQuantityParams({
    required this.cartItemId,
    required this.quantity,
  });
}

class UpdateCartItemQuantityUseCase
    extends UseCaseParam<bool, UpdateCartItemQuantityParams> {
  final CartRepo cartRepo;

  UpdateCartItemQuantityUseCase({required this.cartRepo});

  @override
  Future<Either<Failure, bool>> call(UpdateCartItemQuantityParams param) {
    return cartRepo.updateCartItemQuantity(
      cartItemId: param.cartItemId,
      quantity: param.quantity,
    );
  }
}
