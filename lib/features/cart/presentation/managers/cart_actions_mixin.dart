import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/cart/domain/use_case/add_to_cart_use_case.dart';
import 'package:heraj/features/cart/domain/use_case/remove_cart_item_use_case.dart';
import 'package:heraj/features/cart/domain/use_case/update_cart_item_quantity_use_case.dart';
import 'package:heraj/features/cart/presentation/managers/fetch_cart_provider.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/ui.dart';

mixin CartActionsMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  Future<bool> addProductToCart({
    required int productId,
    int? productVariantId,
    List<int>? additionIds,
    int quantity = 1,
    String loadingKey = 'addToCart',
    bool showSnackBar = true,
  }) async {
    ref.read(isLoadingProvider(loadingKey).notifier).state = true;
    try {
      final res = await getIt<AddToCartUseCase>().call(
        AddToCartParams(
          productId: productId,
          productVariantId: productVariantId,
          additionIds: additionIds,
          quantity: quantity,
        ),
      );
      return res.fold(
        (l) {
          UIHelper.showAlert(l.message, type: DialogType.error);
          return false;
        },
        (_) {
          ref.invalidate(fetchCartProvider);
          if (showSnackBar) {
            UIHelper.showGlobalSnackBar(text: 'Added to cart'.tr);
          }
          return true;
        },
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider(loadingKey).notifier).state = false;
      }
    }
  }

  Future<bool> updateCartItemQuantity({
    required int cartItemId,
    required int quantity,
    String loadingKey = 'updateCartQty',
  }) async {
    ref.read(isLoadingProvider(loadingKey).notifier).state = true;
    try {
      final res = await getIt<UpdateCartItemQuantityUseCase>().call(
        UpdateCartItemQuantityParams(
          cartItemId: cartItemId,
          quantity: quantity,
        ),
      );
      return res.fold(
        (l) {
          UIHelper.showAlert(l.message, type: DialogType.error);
          return false;
        },
        (_) {
          ref.invalidate(fetchCartProvider);
          return true;
        },
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider(loadingKey).notifier).state = false;
      }
    }
  }

  Future<bool> removeCartItem({
    required int cartItemId,
    String loadingKey = 'removeCart',
    bool invalidateOnSuccess = true,
    bool showSnackBar = true,
  }) async {
    ref.read(isLoadingProvider(loadingKey).notifier).state = true;
    try {
      final res = await getIt<RemoveCartItemUseCase>().call(cartItemId);
      return res.fold(
        (l) {
          UIHelper.showAlert(l.message, type: DialogType.error);
          return false;
        },
        (_) {
          if (invalidateOnSuccess) {
            ref.invalidate(fetchCartProvider);
          }
          if (showSnackBar) {
            UIHelper.showGlobalSnackBar(text: 'Removed from cart'.tr);
          }
          return true;
        },
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider(loadingKey).notifier).state = false;
      }
    }
  }
}
