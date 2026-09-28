import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../repo/favorites_repo.dart';

class RemoveWishlistItemUseCase extends UseCaseParam<bool, int> {
  final FavoritesRepo favoritesRepo;

  RemoveWishlistItemUseCase({required this.favoritesRepo});

  @override
  Future<Either<Failure, bool>> call(int param) {
    return favoritesRepo.removeWishlistItem(param);
  }
}
