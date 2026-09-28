import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/cart_model.dart';
import '../repo/cart_repo.dart';

class FetchCartParams {
  final int? addressId;
  final List<String> couponCodes;

  const FetchCartParams({
    this.addressId,
    this.couponCodes = const [],
  });
}

class FetchCartUseCase extends UseCaseParam<CartModel, FetchCartParams> {
  final CartRepo cartRepo;

  FetchCartUseCase({required this.cartRepo});

  @override
  Future<Either<Failure, CartModel>> call(FetchCartParams param) {
    return cartRepo.getCart(
      addressId: param.addressId,
      couponCodes: param.couponCodes.isEmpty ? null : param.couponCodes,
    );
  }
}
