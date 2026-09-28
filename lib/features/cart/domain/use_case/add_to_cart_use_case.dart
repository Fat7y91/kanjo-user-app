import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../repo/cart_repo.dart';

class AddToCartParams {
  final int productId;
  final int? productVariantId;
  final List<int>? additionIds;
  final int quantity;

  const AddToCartParams({
    required this.productId,
    this.productVariantId,
    this.additionIds,
    this.quantity = 1,
  });
}

class AddToCartUseCase extends UseCaseParam<bool, AddToCartParams> {
  final CartRepo cartRepo;

  AddToCartUseCase({required this.cartRepo});

  @override
  Future<Either<Failure, bool>> call(AddToCartParams param) {
    return cartRepo.addToCart(
      productId: param.productId,
      productVariantId: param.productVariantId,
      additionIds: param.additionIds,
      quantity: param.quantity,
    );
  }
}
