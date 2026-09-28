import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../repo/favorites_repo.dart';

class ToggleWishlistParams {
  final int productId;
  final int? productVariantId;

  const ToggleWishlistParams({
    required this.productId,
    this.productVariantId,
  });
}

class ToggleWishlistUseCase extends UseCaseParam<bool, ToggleWishlistParams> {
  final FavoritesRepo favoritesRepo;

  ToggleWishlistUseCase({required this.favoritesRepo});

  @override
  Future<Either<Failure, bool>> call(ToggleWishlistParams param) {
    return favoritesRepo.toggleWishlist(
      productId: param.productId,
      productVariantId: param.productVariantId,
    );
  }
}
