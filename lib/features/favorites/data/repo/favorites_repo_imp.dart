import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/repo/favorites_repo.dart';
import '../data_source/favorites_data_source.dart';
import '../models/wishlist_item_model.dart';

class FavoritesRepoImp implements FavoritesRepo {
  final FavoritesDataSource dataSource;

  FavoritesRepoImp({required this.dataSource});

  @override
  Future<Either<Failure, List<WishlistItemModel>>> getWishlist() async {
    try {
      return Right(await dataSource.getWishlist());
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleWishlist({
    required int productId,
    int? productVariantId,
  }) async {
    try {
      return Right(
        await dataSource.toggleWishlist(
          productId: productId,
          productVariantId: productVariantId,
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
  Future<Either<Failure, bool>> addToWishlist({
    required int productId,
    int? productVariantId,
  }) async {
    try {
      return Right(
        await dataSource.addToWishlist(
          productId: productId,
          productVariantId: productVariantId,
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
  Future<Either<Failure, bool>> removeWishlistItem(int wishlistItemId) async {
    try {
      return Right(await dataSource.removeWishlistItem(wishlistItemId));
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }
}
