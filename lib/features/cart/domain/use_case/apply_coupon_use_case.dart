import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/cart_model.dart';
import '../repo/cart_repo.dart';

class ApplyCouponParams {
  final List<String> couponCodes;
  final int? addressId;
  final int? vendorId;

  const ApplyCouponParams({
    required this.couponCodes,
    this.addressId,
    this.vendorId,
  });
}

class ApplyCouponUseCase extends UseCaseParam<CartModel, ApplyCouponParams> {
  final CartRepo cartRepo;

  ApplyCouponUseCase({required this.cartRepo});

  @override
  Future<Either<Failure, CartModel>> call(ApplyCouponParams param) {
    return cartRepo.applyCoupon(
      couponCodes: param.couponCodes,
      addressId: param.addressId,
      vendorId: param.vendorId,
    );
  }
}
