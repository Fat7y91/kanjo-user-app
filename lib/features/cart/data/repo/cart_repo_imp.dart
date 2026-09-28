import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/checkout_params.dart';
import '../../domain/repo/cart_repo.dart';
import '../data_source/cart_data_source.dart';
import '../models/cart_model.dart';

class CartRepoImp implements CartRepo {
  final CartDataSource dataSource;

  CartRepoImp({required this.dataSource});

  @override
  Future<Either<Failure, CartModel>> getCart({
    int? addressId,
    List<String>? couponCodes,
  }) async {
    try {
      return Right(
        await dataSource.getCart(
          addressId: addressId,
          couponCodes: couponCodes,
        ),
      );
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, bool>> addToCart({
    required int productId,
    int? productVariantId,
    List<int>? additionIds,
    required int quantity,
  }) async {
    try {
      return Right(
        await dataSource.addToCart(
          productId: productId,
          productVariantId: productVariantId,
          additionIds: additionIds,
          quantity: quantity,
        ),
      );
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, bool>> updateCartItemQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      return Right(
        await dataSource.updateCartItemQuantity(
          cartItemId: cartItemId,
          quantity: quantity,
        ),
      );
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, bool>> removeFromCart(int cartItemId) async {
    try {
      return Right(await dataSource.removeFromCart(cartItemId));
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, CartModel>> applyCoupon({
    required List<String> couponCodes,
    int? addressId,
    int? vendorId,
  }) async {
    try {
      return Right(
        await dataSource.applyCoupon(
          couponCodes: couponCodes,
          addressId: addressId,
          vendorId: vendorId,
        ),
      );
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, CheckoutResult>> checkout(CheckoutParams params) async {
    try {
      return Right(await dataSource.checkout(params));
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }
}
