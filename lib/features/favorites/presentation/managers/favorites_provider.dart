import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/favorites/data/models/wishlist_item_model.dart';
import 'package:heraj/features/favorites/domain/use_case/fetch_wishlist_use_case.dart';
import 'package:heraj/main.dart';

final fetchWishlistProvider =
    FutureProvider.autoDispose<List<WishlistItemModel>>((ref) async {
  final res = await getIt<FetchWishlistUseCase>().call();
  return res.fold((l) => throw l, (r) => r);
});

bool isProductInWishlist(
  List<WishlistItemModel> items, {
  required int productId,
  int? productVariantId,
}) {
  return items.any(
    (item) =>
        item.productId == productId &&
        item.productVariantId == productVariantId,
  );
}
