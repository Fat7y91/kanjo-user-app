import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/favorites/data/models/wishlist_item_model.dart';
import 'package:heraj/features/products/presentation/view/product_details_screen.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';

class FavoriteItemCard extends StatefulWidget {
  const FavoriteItemCard({
    super.key,
    required this.item,
    required this.languageCode,
    required this.isRemoving,
    required this.onRemove,
  });

  final WishlistItemModel item;
  final String languageCode;
  final bool isRemoving;
  final VoidCallback onRemove;

  @override
  State<FavoriteItemCard> createState() => _FavoriteItemCardState();
}

class _FavoriteItemCardState extends State<FavoriteItemCard>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> _pressedNotifier = ValueNotifier(false);
  late final AnimationController _heartController;
  late final Animation<double> _heartScaleAnimation;
  late final Animation<double> _heartRotationAnimation;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heartScaleAnimation = Tween<double>(begin: 1, end: 1.3).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );
    _heartRotationAnimation = Tween<double>(begin: 0, end: 0.2).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    _pressedNotifier.dispose();
    super.dispose();
  }

  void _handleHeartTap() {
    if (widget.isRemoving) return;
    _heartController.forward().then((_) {
      if (mounted) _heartController.reverse();
    });
    widget.onRemove();
  }

  String _priceText() {
    final product = widget.item.product;
    if (product?.displayPrice.isNotEmpty == true) {
      return '${product!.displayPrice} ${'EGP'.tr}';
    }
    final price = product?.price ?? 0;
    final formatted = price % 1 == 0
        ? price.toStringAsFixed(0)
        : price.toStringAsFixed(2);
    return '$formatted ${'EGP'.tr}';
  }

  String? _comparePriceText() {
    final product = widget.item.product;
    if (product == null || product.discount <= 0) return null;
    final original = product.discountType == 'percent'
        ? product.price / (1 - (product.discount / 100))
        : product.price + product.discount;
    if (original <= product.price) return null;
    final formatted = original % 1 == 0
        ? original.toStringAsFixed(0)
        : original.toStringAsFixed(2);
    return '$formatted ${'EGP'.tr}';
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.item.product;
    final name = product?.name.localized(widget.languageCode) ?? '';
    final categoryName = product?.categories.isNotEmpty == true
        ? product!.categories.first.name.localized(widget.languageCode)
        : '';
    final rating = product?.ratingSummary.average;
    final comparePrice = _comparePriceText();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GestureDetector(
        onTap: product == null
            ? null
            : () => Get.to(
                  () => ProductDetailsScreen(
                    productId: product.id,
                    initialProduct: product,
                  ),
                ),
        onTapDown: (_) => _pressedNotifier.value = true,
        onTapUp: (_) => _pressedNotifier.value = false,
        onTapCancel: () => _pressedNotifier.value = false,
        child: ValueListenableBuilder<bool>(
          valueListenable: _pressedNotifier,
          builder: (context, isPressed, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              transformAlignment: Alignment.center,
              transform: Matrix4.identity()..scale(isPressed ? 0.98 : 1.0),
              child: child,
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColor.white,
                  AppColor.primary2.withAlpha(77),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary.withAlpha(26),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: AppColor.primary.withAlpha(51),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primary.withAlpha(51),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          ImageOrSvg(
                            product?.thumbnailImageUrl,
                            height: 76,
                            width: 76,
                            fit: BoxFit.cover,
                            pickImageOnNull: true,
                            assetImageOnNull: AppAssets.homeCategoryFood,
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withAlpha(26),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppFont.font14W700Black,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (categoryName.isNotEmpty) ...[
                          const Gap(6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.primary.withAlpha(38),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColor.primary.withAlpha(77),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.category_rounded,
                                  size: 11,
                                  color: AppColor.primary,
                                ),
                                const Gap(4),
                                Flexible(
                                  child: Text(
                                    categoryName,
                                    style: AppFont.font12W600Primary.copyWith(
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Gap(8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                _priceText(),
                                style: AppFont.font14W700Black.copyWith(
                                  color: AppColor.primary,
                                ),
                              ),
                            ),
                            if (comparePrice != null) ...[
                              const Gap(6),
                              Flexible(
                                child: Text(
                                  comparePrice,
                                  style: AppFont.font12W600Black.copyWith(
                                    color: AppColor.grey2,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (rating != null && rating > 0) ...[
                          const Gap(6),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: AppColor.orange,
                              ),
                              const Gap(4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: AppFont.font12w400Black.copyWith(
                                  color: AppColor.grey2,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: AnimatedBuilder(
                      animation: _heartController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _heartScaleAnimation.value,
                          child: Transform.rotate(
                            angle: _heartRotationAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.isRemoving ? null : _handleHeartTap,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColor.danger.withAlpha(38),
                                  AppColor.danger.withAlpha(64),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColor.danger.withAlpha(77),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: AppColor.danger,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
