import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/features/cart/data/models/cart_item_model.dart';
import 'package:heraj/features/cart/data/models/cart_model.dart';
import 'package:heraj/features/cart/domain/use_case/fetch_cart_use_case.dart';
import 'package:heraj/main.dart';

final fetchCartProvider = FutureProvider.autoDispose<CartModel>((ref) async {
  if ((dataManager.getToken() ?? '').isEmpty) {
    return CartModel.fromJson(const {});
  }
  final res = await getIt<FetchCartUseCase>().call(const FetchCartParams());
  return res.fold((l) => throw l, (r) => r);
});

bool isProductInCart(
  List<CartItemModel> items, {
  required int productId,
  int? productVariantId,
}) {
  return findCartItem(
        items,
        productId: productId,
        productVariantId: productVariantId,
      ) !=
      null;
}

CartItemModel? findCartItem(
  List<CartItemModel> items, {
  required int productId,
  int? productVariantId,
}) {
  final variantId =
      (productVariantId == null || productVariantId == 0) ? null : productVariantId;
  for (final item in items) {
    final itemVariantId =
        (item.productVariantId == null || item.productVariantId == 0)
            ? null
            : item.productVariantId;
    if (item.productId == productId && itemVariantId == variantId) {
      return item;
    }
  }
  return null;
}
