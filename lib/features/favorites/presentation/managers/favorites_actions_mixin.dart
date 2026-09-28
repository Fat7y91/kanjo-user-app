import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../../../../core/service/loading_provider.dart';
import '../../../../../main.dart';
import '../../../../../ui/ui.dart';
import '../../domain/use_case/remove_wishlist_item_use_case.dart';
import '../../domain/use_case/toggle_wishlist_use_case.dart';
import 'favorites_provider.dart';

mixin FavoritesActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  Future<bool> toggleWishlist({
    required int productId,
    int? productVariantId,
  }) async {
    try {
      ref.read(isLoadingProvider('toggleWishlist').notifier).state = true;
      final res = await getIt<ToggleWishlistUseCase>().call(
        ToggleWishlistParams(
          productId: productId,
          productVariantId: productVariantId,
        ),
      );
      return res.fold(
        (l) {
          UIHelper.showAlert(l.message, type: DialogType.error);
          return false;
        },
        (_) {
          ref.invalidate(fetchWishlistProvider);
          return true;
        },
      );
    } finally {
      ref.read(isLoadingProvider('toggleWishlist').notifier).state = false;
    }
  }

  Future<bool> removeWishlistItem(int wishlistItemId) async {
    try {
      ref.read(isLoadingProvider('removeWishlist').notifier).state = true;
      final res = await getIt<RemoveWishlistItemUseCase>().call(wishlistItemId);
      return res.fold(
        (l) {
          UIHelper.showAlert(l.message, type: DialogType.error);
          return false;
        },
        (_) {
          UIHelper.showAlert('Removed from favorites'.tr);
          ref.invalidate(fetchWishlistProvider);
          return true;
        },
      );
    } finally {
      ref.read(isLoadingProvider('removeWishlist').notifier).state = false;
    }
  }
}
