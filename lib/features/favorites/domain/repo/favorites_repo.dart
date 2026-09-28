import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/wishlist_item_model.dart';

abstract class FavoritesRepo {
  Future<Either<Failure, List<WishlistItemModel>>> getWishlist();

  Future<Either<Failure, bool>> toggleWishlist({
    required int productId,
    int? productVariantId,
  });

  Future<Either<Failure, bool>> addToWishlist({
    required int productId,
    int? productVariantId,
  });

  Future<Either<Failure, bool>> removeWishlistItem(int wishlistItemId);
}
