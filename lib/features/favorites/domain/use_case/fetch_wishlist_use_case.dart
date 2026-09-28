import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/wishlist_item_model.dart';
import '../repo/favorites_repo.dart';

class FetchWishlistUseCase extends UseCaseNoParam<List<WishlistItemModel>> {
  final FavoritesRepo favoritesRepo;

  FetchWishlistUseCase({required this.favoritesRepo});

  @override
  Future<Either<Failure, List<WishlistItemModel>>> call() {
    return favoritesRepo.getWishlist();
  }
}
