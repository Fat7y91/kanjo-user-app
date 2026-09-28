import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/cart/domain/use_case/add_to_cart_use_case.dart';
import 'package:heraj/features/cart/presentation/managers/fetch_cart_provider.dart';
import 'package:heraj/features/favorites/domain/use_case/toggle_wishlist_use_case.dart';
import 'package:heraj/features/favorites/presentation/managers/favorites_provider.dart';
import 'package:heraj/features/offers/data/models/offer_model.dart';
import 'package:heraj/features/products/presentation/managers/product_details_provider.dart';
import 'package:heraj/features/share/domain/entities/share_link_type.dart';
import 'package:heraj/features/share/presentation/managers/share_actions.dart';
import 'package:heraj/features/products/presentation/view/widgets/product_variant_picker_sheet.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:heraj/ui/ui.dart';
import '../../../../../config/app_assets.dart';
import '../../../../../config/app_font.dart';
import '../../../../../ui/shared_widgets/image_or_svg.dart';
import '../../../data/models/product_model.dart';
import '../product_details_screen.dart';

class ProductCard extends ConsumerWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.languageCode,
    this.offer,
  });

  final ProductModel product;
  final String languageCode;
  final OfferModel? offer;

  bool get _isVariantProduct {
    final type = product.type.toLowerCase().trim();
    return type == 'variant' ||
        type == 'variants' ||
        product.variants.isNotEmpty;
  }

  String _formatAmount(double amount) {
    return amount % 1 == 0
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
  }

  String _formatMoney(double amount) => '${_formatAmount(amount)} ${'EGP'.tr}';

  String _formatPriceRange(double min, double max) {
    if ((min - max).abs() < 0.0001) return _formatMoney(min);
    return '${_formatAmount(min)}-${_formatAmount(max)} ${'EGP'.tr}';
  }

  double _applyOfferPercent(double base, double percent) {
    final value = base * (1 - (percent / 100));
    return value < 0 ? 0 : value;
  }

  /// Same discount math as product details: original = variant/list price,
  /// current = after product discount or offer percent.
  ({String current, String? original, String? badge}) get _priceDisplay {
    final offerPercent = offer?.rules.percent;
    final hasOffer = offerPercent != null && offerPercent > 0;
    final original = product.originalListPriceRange(offerPercent: offerPercent);

    if (product.hasDiscount) {
      return (
        current: _formatPriceRange(
          product.applyDiscount(original.min),
          product.applyDiscount(original.max),
        ),
        original: _formatPriceRange(original.min, original.max),
        badge: product.discountBadgeText(),
      );
    }

    if (hasOffer) {
      final percent = offerPercent;
      final badgeValue = percent % 1 == 0
          ? percent.toInt().toString()
          : percent.toString();
      return (
        current: _formatPriceRange(
          _applyOfferPercent(original.min, percent),
          _applyOfferPercent(original.max, percent),
        ),
        original: _formatPriceRange(original.min, original.max),
        badge: '-$badgeValue%',
      );
    }

    return (
      current: _formatPriceRange(original.min, original.max),
      original: null,
      badge: null,
    );
  }

  Future<void> _toggleWishlist(WidgetRef ref) async {
    final res = await getIt<ToggleWishlistUseCase>().call(
      ToggleWishlistParams(productId: product.id),
    );
    res.fold(
      (l) => UIHelper.showAlert(l.message, type: DialogType.error),
      (_) => ref.invalidate(fetchWishlistProvider),
    );
  }

  Future<void> _addToCart(
    WidgetRef ref, {
    int? productVariantId,
    int quantity = 1,
  }) async {
    final loadingKey = 'addToCart_${product.id}';
    ref.read(isLoadingProvider(loadingKey).notifier).state = true;
    try {
      final res = await getIt<AddToCartUseCase>().call(
        AddToCartParams(
          productId: product.id,
          productVariantId: productVariantId,
          quantity: quantity,
        ),
      );
      res.fold(
        (l) => UIHelper.showAlert(l.message, type: DialogType.error),
        (_) {
          ref.invalidate(fetchCartProvider);
          UIHelper.showGlobalSnackBar(text: 'Added to cart'.tr);
        },
      );
    } finally {
      ref.read(isLoadingProvider(loadingKey).notifier).state = false;
    }
  }

  Future<void> _onCartTap(BuildContext context, WidgetRef ref) async {
    if (!_isVariantProduct) {
      await _addToCart(ref);
      return;
    }

    var variants = product.variants;
    if (variants.isEmpty) {
      final loadingKey = 'addToCart_${product.id}';
      ref.read(isLoadingProvider(loadingKey).notifier).state = true;
      try {
        final details =
            await ref.read(productDetailsProvider(product.id).future);
        variants = details.variants;
      } catch (e) {
        UIHelper.showAlert(e.toString(), type: DialogType.error);
        return;
      } finally {
        ref.read(isLoadingProvider(loadingKey).notifier).state = false;
      }
    }

    if (variants.isEmpty) {
      await _addToCart(ref);
      return;
    }

    if (!context.mounted) return;
    final selected = await showProductVariantPickerSheet(
      context: context,
      variants: variants,
      languageCode: languageCode,
      productImageUrl: product.thumbnailImageUrl,
    );
    if (selected == null) return;
    await _addToCart(
      ref,
      productVariantId: selected.variant.id,
      quantity: selected.quantity,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingKey = 'addToCart_${product.id}';
    final isAdding = ref.watch(isLoadingProvider(loadingKey));
    final isInCart = ref.watch(fetchCartProvider).maybeWhen(
      data: (cart) => cart.items.any((item) => item.productId == product.id),
      orElse: () => false,
    );
    final isFavorite = ref.watch(fetchWishlistProvider).maybeWhen(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (items) => items.any((item) => item.productId == product.id),
      orElse: () => false,
    );

    return InkWell(
      onTap: () => Get.to(
        () => ProductDetailsScreen(
          productId: product.id,
          initialProduct: product,
          offer: offer,
        ),
      ),
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          PositionedDirectional(
            top: 0,
            end: 0,
            start: 0,
            height: 120,
            child: SvgPicture.asset(
              AppAssets.productBack,
              fit: BoxFit.fill,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _TopIcon(
                      icon: isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFavorite ? AppColor.danger : Colors.white,
                      onTap: () => _toggleWishlist(ref),
                    ),
                    const Spacer(),
                    _TopIcon(
                      icon: Icons.share_outlined,
                      onTap: () => shareItem(
                        type: ShareLinkType.product,
                        id: product.id,
                        ref: ref,
                      ),
                    ),
                  ],
                ),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: ImageOrSvg(
                      product.thumbnailImageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      pickImageOnNull: true,
                      assetImageOnNull: AppAssets.homeCategoryFood,
                    ),
                  ),
                ),
                const Gap(10),
                Text(
                  product.name.localized(languageCode),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.font14W700Black,
                ),
                const Gap(4),
                Text(
                  product.description.localized(languageCode),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.font12W600NearlyWhite.copyWith(
                    color: AppColor.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Builder(
                        builder: (context) {
                          final prices = _priceDisplay;
                          // Match product-details layout: current, struck original, badge.
                          return Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Text(
                                prices.current,
                                style: AppFont.font16W700Black.copyWith(
                                  color: const Color(0xFFFFB36D),
                                ),
                              ),
                              if (prices.original != null)
                                Text(
                                  prices.original!,
                                  style: AppFont.font12w500Grey2.copyWith(
                                    color: AppColor.textGrey,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: AppColor.priceStrikeRed,
                                  ),
                                ),
                              if (prices.badge != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColor.priceStrikeRed.withAlpha(26),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    prices.badge!,
                                    style: AppFont.font12W600Primary.copyWith(
                                      color: AppColor.priceStrikeRed,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    const Gap(8),
                    InkWell(
                      onTap: isAdding
                          ? null
                          : () {
                              if (isInCart) {
                                Get.toNamed('/cart');
                                return;
                              }
                              _onCartTap(context, ref);
                            },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          gradient: AppColor.defaultPrimaryGradient2,
                          borderRadius: const BorderRadiusDirectional.only(
                            topStart: Radius.circular(12),
                            bottomEnd: Radius.circular(12),
                          ),
                        ),
                        child: isAdding
                            ? const Center(child: LoadingWidget(size: 18))
                            : Icon(
                                isInCart
                                    ? Icons.shopping_cart_rounded
                                    : CupertinoIcons.cart_badge_plus,
                                color: AppColor.white,
                              ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCardPlaceholder extends StatelessWidget {
  const ProductCardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFFECECEC),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Gap(10),
          Container(
            height: 14,
            width: double.infinity,
            color: const Color(0xFFECECEC),
          ),
          const Gap(8),
          Container(
            height: 12,
            width: 90,
            color: const Color(0xFFECECEC),
          ),
          const Gap(12),
          Container(
            height: 16,
            width: 70,
            color: const Color(0xFFECECEC),
          ),
        ],
      ),
    );
  }
}

class _TopIcon extends StatelessWidget {
  const _TopIcon({
    required this.icon,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: color ?? Colors.white),
      ),
    );
  }
}
