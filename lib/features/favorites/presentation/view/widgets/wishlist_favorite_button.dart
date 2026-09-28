import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/favorites/domain/use_case/toggle_wishlist_use_case.dart';
import 'package:heraj/features/favorites/presentation/managers/favorites_provider.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:heraj/ui/ui.dart';

class WishlistFavoriteButton extends ConsumerWidget {
  const WishlistFavoriteButton({
    super.key,
    required this.productId,
    this.productVariantId,
    this.size = 24,
  });

  final int productId;
  final int? productVariantId;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(fetchWishlistProvider);
    final isLoading = ref.watch(isLoadingProvider('toggleWishlist'));
    final isFavorite = wishlistAsync.maybeWhen(
      data: (items) => isProductInWishlist(
        items,
        productId: productId,
        productVariantId: productVariantId,
      ),
      orElse: () => false,
    );

    if (isLoading) {
      return SizedBox(
        width: size + 24,
        height: size + 24,
        child: const Center(child: LoadingWidget(size: 18)),
      );
    }

    return IconButton(
      onPressed: () async {
        ref.read(isLoadingProvider('toggleWishlist').notifier).state = true;
        try {
          final res = await getIt<ToggleWishlistUseCase>().call(
            ToggleWishlistParams(
              productId: productId,
              productVariantId: productVariantId,
            ),
          );
          res.fold(
            (l) => UIHelper.showAlert(l.message, type: DialogType.error),
            (_) => ref.invalidate(fetchWishlistProvider),
          );
        } finally {
          ref.read(isLoadingProvider('toggleWishlist').notifier).state = false;
        }
      },
      icon: isFavorite
          ? Icon(
              Icons.favorite_rounded,
              color: AppColor.danger,
              size: size,
            )
          : SvgPicture.asset(
              AppAssets.heart,
              height: size,
            ),
    );
  }
}
