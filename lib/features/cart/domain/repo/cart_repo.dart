import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/cart_model.dart';
import '../entities/checkout_params.dart';

abstract class CartRepo {
  Future<Either<Failure, CartModel>> getCart({
    int? addressId,
    List<String>? couponCodes,
  });

  Future<Either<Failure, bool>> addToCart({
    required int productId,
    int? productVariantId,
    List<int>? additionIds,
    required int quantity,
  });

  Future<Either<Failure, bool>> updateCartItemQuantity({
    required int cartItemId,
    required int quantity,
  });

  Future<Either<Failure, bool>> removeFromCart(int cartItemId);

  Future<Either<Failure, CartModel>> applyCoupon({
    required List<String> couponCodes,
    int? addressId,
    int? vendorId,
  });

  Future<Either<Failure, CheckoutResult>> checkout(CheckoutParams params);
}
