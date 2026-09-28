import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/cart/data/models/cart_item_model.dart';
import 'package:heraj/features/cart/presentation/managers/cart_actions_mixin.dart';
import 'package:heraj/features/cart/presentation/managers/fetch_cart_provider.dart';
import 'package:heraj/features/favorites/presentation/view/widgets/wishlist_favorite_button.dart';
import 'package:heraj/features/offers/data/models/offer_model.dart';
import 'package:heraj/features/offers/presentation/view/widgets/offer_banner.dart';
import 'package:heraj/features/products/data/models/product_model.dart';
import 'package:heraj/features/products/domain/entities/product_addition_entity.dart';
import 'package:heraj/features/products/domain/entities/product_variant_entity.dart';
import 'package:heraj/features/products/presentation/managers/product_details_provider.dart';
import 'package:heraj/features/share/domain/entities/share_link_type.dart';
import 'package:heraj/features/share/presentation/managers/share_actions.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import '../../../../config/app_assets.dart';
import '../../../../config/app_font.dart';
import 'widgets/product_details_shimmer.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.productId,
    this.initialProduct,
    this.offer,
  });

  final int productId;
  final ProductModel? initialProduct;
  final OfferModel? offer;

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen>
    with CartActionsMixin {
  late final ValueNotifier<int> _qty;
  late final ValueNotifier<int?> _selectedVariantId;
  late final ValueNotifier<Set<int>> _selectedAdditionIds;
  late final ValueNotifier<int> _selectedGalleryIndex;

  @override
  void initState() {
    super.initState();
    _qty = ValueNotifier(1);
    _selectedVariantId = ValueNotifier(
      _defaultVariantId(widget.initialProduct?.variants ?? const []),
    );
    _selectedAdditionIds = ValueNotifier(<int>{});
    _selectedGalleryIndex = ValueNotifier(0);
    _selectedVariantId.addListener(_syncFromCart);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncFromCart();
    });
  }

  int? _defaultVariantId(List<ProductVariantEntity> variants) {
    if (variants.isEmpty) return null;
    final active = variants.where((v) => v.isActive).toList();
    final pool = active.isNotEmpty ? active : variants;
    return pool.first.id;
  }

  @override
  void dispose() {
    _selectedVariantId.removeListener(_syncFromCart);
    _qty.dispose();
    _selectedVariantId.dispose();
    _selectedAdditionIds.dispose();
    _selectedGalleryIndex.dispose();
    super.dispose();
  }

  int? _cartVariantId(ProductModel? product) {
    if (product == null || product.variants.isEmpty) return null;
    return _normalizeVariantId(_selectedVariantId.value);
  }

  int? _normalizeVariantId(int? id) =>
      (id == null || id == 0) ? null : id;

  CartItemModel? _findCurrentCartItem(ProductModel? product) {
    final cart = ref.read(fetchCartProvider).valueOrNull;
    if (cart == null) return null;
    return findCartItem(
      cart.items,
      productId: widget.productId,
      productVariantId: _cartVariantId(product),
    );
  }

  void _syncFromCart() {
    final product =
        ref.read(productDetailsProvider(widget.productId)).valueOrNull ??
            widget.initialProduct;
    final item = _findCurrentCartItem(product);
    final nextQty = item?.quantity ?? 1;
    if (_qty.value != nextQty) {
      _qty.value = nextQty;
    }

    final nextAdditions = item == null
        ? <int>{}
        : item.additions.map((e) => e.id).toSet();
    if (!_setEquals(_selectedAdditionIds.value, nextAdditions)) {
      _selectedAdditionIds.value = nextAdditions;
    }
  }

  bool _setEquals(Set<int> a, Set<int> b) {
    if (a.length != b.length) return false;
    for (final value in a) {
      if (!b.contains(value)) return false;
    }
    return true;
  }

  /// Same behavior as cart line items: +/− use add-to-cart delta; qty 1 removes.
  Future<void> _onQtyChanged(int next, ProductModel product) async {
    final previous = _qty.value;
    final item = _findCurrentCartItem(product);

    // Not in cart yet — only adjust local qty for the upcoming add.
    if (item == null) {
      final clamped = next < 1 ? 1 : next;
      if (clamped == previous) return;
      _qty.value = clamped;
      return;
    }

    // Cart qty is 1 (or going below): remove the line like the cart tile.
    if (next < previous && item.quantity <= 1) {
      final ok = await removeCartItem(
        cartItemId: item.id,
        loadingKey: 'removeCart_${item.id}',
      );
      if (ok && mounted) {
        _qty.value = 1;
      }
      return;
    }

    if (next == previous || next < 1) return;
    _qty.value = next;

    final ok = await addProductToCart(
      productId: product.id,
      productVariantId: _normalizeVariantId(item.productVariantId),
      quantity: next - previous,
      loadingKey: next > previous
          ? 'addCartQty_${item.id}'
          : 'updateCartQty_${item.id}',
      showSnackBar: false,
    );
    if (!ok && mounted) {
      _qty.value = previous;
    }
  }

  List<String> _galleryUrls(ProductModel product) {
    final urls = <String>[];
    void add(String? url) {
      if (url == null || url.isEmpty) return;
      if (!urls.contains(url)) urls.add(url);
    }

    add(product.thumbnailImageUrl);
    for (final item in product.gallery) {
      add(item.imageUrl);
    }
    for (final variant in product.variants) {
      add(variant.imageUrl);
    }
    return urls;
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

  /// Current + optional original/badge when product discount or offer applies.
  ({String current, String? original, String? badge}) _priceDisplay(
    ProductModel product,
    ProductVariantEntity? variant,
  ) {
    final offerPercent = widget.offer?.rules.percent;
    final hasOffer = offerPercent != null && offerPercent > 0;

    // Selected variant: single price (+ strikethrough original when discounted).
    if (variant != null) {
      final base = variant.price;
      if (product.hasDiscount) {
        return (
          current: _formatMoney(product.applyDiscount(base)),
          original: _formatMoney(base),
          badge: product.discountBadgeText(),
        );
      }
      if (hasOffer) {
        final percent = offerPercent;
        final badgeValue = percent % 1 == 0
            ? percent.toInt().toString()
            : percent.toString();
        return (
          current: _formatMoney(_applyOfferPercent(base, percent)),
          original: _formatMoney(base),
          badge: '-$badgeValue%',
        );
      }
      return (current: _formatMoney(base), original: null, badge: null);
    }

    // No variant selected: same original-range resolution as the product card.
    final original =
        product.originalListPriceRange(offerPercent: offerPercent);

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

  String _heroImage(ProductModel product, ProductVariantEntity? variant) {
    if (variant?.imageUrl != null && variant!.imageUrl!.isNotEmpty) {
      return variant.imageUrl!;
    }
    if (product.thumbnailImageUrl != null &&
        product.thumbnailImageUrl!.isNotEmpty) {
      return product.thumbnailImageUrl!;
    }
    if (product.gallery.isNotEmpty) {
      return product.gallery.first.imageUrl;
    }
    return '';
  }

  Future<void> _onAddToCart(ProductModel product) async {
    final additionIds = _selectedAdditionIds.value.toList();
    await addProductToCart(
      productId: product.id,
      productVariantId:
          product.variants.isEmpty ? null : _selectedVariantId.value,
      additionIds: additionIds.isEmpty ? null : additionIds,
      quantity: _qty.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final asyncProduct = ref.watch(productDetailsProvider(widget.productId));
    final isAdding = ref.watch(isLoadingProvider('addToCart'));
    final cartAsync = ref.watch(fetchCartProvider);
    final product = asyncProduct.valueOrNull ?? widget.initialProduct;
    final cartItem = cartAsync.maybeWhen(
      data: (cart) => findCartItem(
        cart.items,
        productId: widget.productId,
        productVariantId: _cartVariantId(product),
      ),
      orElse: () => null,
    );
    final isIncrementingQty = cartItem == null
        ? false
        : ref.watch(isLoadingProvider('addCartQty_${cartItem.id}'));
    final isDecrementingQty = cartItem == null
        ? false
        : ref.watch(isLoadingProvider('updateCartQty_${cartItem.id}'));
    final isRemovingQty = cartItem == null
        ? false
        : ref.watch(isLoadingProvider('removeCart_${cartItem.id}'));
    final isUpdatingQty =
        isIncrementingQty || isDecrementingQty || isRemovingQty;
    final isInCart = cartItem != null;

    ref.listen(fetchCartProvider, (previous, next) {
      next.whenData((_) {
        if (mounted) _syncFromCart();
      });
    });

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.offer != null)
            OfferBanner(offer: widget.offer!, applySafeArea: false),
          if (product == null && asyncProduct.isLoading)
            const ProductDetailsBottomBarShimmer()
          else
            ValueListenableBuilder<int?>(
              valueListenable: _selectedVariantId,
              builder: (context, variantId, _) {
                final cartVariantId = product == null || product.variants.isEmpty
                    ? null
                    : _normalizeVariantId(variantId);
                final isInCart = cartAsync.maybeWhen(
                  data: (cart) => isProductInCart(
                    cart.items,
                    productId: widget.productId,
                    productVariantId: cartVariantId,
                  ),
                  orElse: () => false,
                );

                return _BottomActionsBar(
                  isAdding: isAdding,
                  isInCart: isInCart,
                  onAddToCart: () {
                    if (product == null) return;
                    if (isInCart) {
                      Get.toNamed('/cart');
                      return;
                    }
                    _onAddToCart(product);
                  },
                  onCompleteOrder: () {
                    final cart = cartAsync.valueOrNull;
                    if (cart != null && cart.isNotEmpty) {
                      Get.toNamed('/checkout', arguments: cart);
                    } else {
                      Get.toNamed('/cart');
                    }
                  },
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  _TopIconButton(
                    icon: Icons.arrow_back_ios,
                    onTap: () => Get.back(closeOverlays: true),
                  ),
                  const Spacer(),
                  Text('Food details'.tr, style: AppFont.font16W700Black),
                  const Spacer(),
                  _TopIconButton(
                    icon: Icons.share_outlined,
                    onTap: () => shareItem(
                      type: ShareLinkType.product,
                      id: widget.productId,
                      ref: ref,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: asyncProduct.customWhen(
                ref: ref,
                refreshable: productDetailsProvider(widget.productId).future,
                loading: () {
                  final initial = widget.initialProduct;
                  if (initial != null) {
                    return _ProductDetailsBody(
                      product: initial,
                      languageCode: languageCode,
                      qty: _qty,
                      selectedVariantId: _selectedVariantId,
                      selectedAdditionIds: _selectedAdditionIds,
                      selectedGalleryIndex: _selectedGalleryIndex,
                      galleryUrls: _galleryUrls(initial),
                      priceDisplay: _priceDisplay,
                      heroImage: _heroImage,
                      qtyEnabled: !isUpdatingQty,
                      isInCart: isInCart,
                      isIncrementingQty: isIncrementingQty,
                      isDecrementingQty: isDecrementingQty || isRemovingQty,
                      onQtyChanged: (next) => _onQtyChanged(next, initial),
                    );
                  }
                  return const ProductDetailsShimmer();
                },
                data: (loadedProduct) {
                  if (_selectedVariantId.value == null &&
                      loadedProduct.variants.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      _selectedVariantId.value =
                          _defaultVariantId(loadedProduct.variants);
                    });
                  }
                  return _ProductDetailsBody(
                    product: loadedProduct,
                    languageCode: languageCode,
                    qty: _qty,
                    selectedVariantId: _selectedVariantId,
                    selectedAdditionIds: _selectedAdditionIds,
                    selectedGalleryIndex: _selectedGalleryIndex,
                    galleryUrls: _galleryUrls(loadedProduct),
                    priceDisplay: _priceDisplay,
                    heroImage: _heroImage,
                    qtyEnabled: !isUpdatingQty,
                    isInCart: isInCart,
                    isIncrementingQty: isIncrementingQty,
                    isDecrementingQty: isDecrementingQty || isRemovingQty,
                    onQtyChanged: (next) =>
                        _onQtyChanged(next, loadedProduct),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductDetailsBody extends StatelessWidget {
  const _ProductDetailsBody({
    required this.product,
    required this.languageCode,
    required this.qty,
    required this.selectedVariantId,
    required this.selectedAdditionIds,
    required this.selectedGalleryIndex,
    required this.galleryUrls,
    required this.priceDisplay,
    required this.heroImage,
    required this.onQtyChanged,
    this.qtyEnabled = true,
    this.isInCart = false,
    this.isIncrementingQty = false,
    this.isDecrementingQty = false,
  });

  final ProductModel product;
  final String languageCode;
  final ValueNotifier<int> qty;
  final ValueNotifier<int?> selectedVariantId;
  final ValueNotifier<Set<int>> selectedAdditionIds;
  final ValueNotifier<int> selectedGalleryIndex;
  final List<String> galleryUrls;
  final ({String current, String? original, String? badge}) Function(
    ProductModel,
    ProductVariantEntity?,
  ) priceDisplay;
  final String Function(ProductModel, ProductVariantEntity?) heroImage;
  final ValueChanged<int> onQtyChanged;
  final bool qtyEnabled;
  final bool isInCart;
  final bool isIncrementingQty;
  final bool isDecrementingQty;

  ProductVariantEntity? _variantById(int? id) {
    if (id == null) return null;
    for (final v in product.variants) {
      if (v.id == id) return v;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final activeVariants = product.variants.where((v) => v.isActive).toList();
    final variants =
        activeVariants.isNotEmpty ? activeVariants : product.variants;

    return ValueListenableBuilder<int?>(
      valueListenable: selectedVariantId,
      builder: (context, variantId, _) {
        final selectedVariant = _variantById(variantId);

        return ListView(
          padding: EdgeInsets.fromLTRB(16, 6, 16, 0).copyWith(
            bottom: MediaQuery.paddingOf(context).bottom + 80,
          ),
          children: [
            ValueListenableBuilder<int>(
              valueListenable: selectedGalleryIndex,
              builder: (context, galleryIndex, _) {
                final selectedImage = galleryUrls.isNotEmpty
                    ? galleryUrls[galleryIndex.clamp(
                        0,
                        galleryUrls.length - 1,
                      )]
                    : heroImage(product, selectedVariant);
                return Column(
                  children: [
                    _HeroImage(imagePath: selectedImage),
                    if (galleryUrls.isNotEmpty) ...[
                      const Gap(8),
                      _GalleryThumbnails(
                        images: galleryUrls,
                        selectedIndex: galleryIndex.clamp(
                          0,
                          galleryUrls.length - 1,
                        ),
                        onSelected: (index) =>
                            selectedGalleryIndex.value = index,
                      ),
                    ],
                  ],
                );
              },
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.name.localized(languageCode),
                    style: AppFont.font20W700Black,
                  ),
                ),
                const Gap(6),
                ValueListenableBuilder<int?>(
                  valueListenable: selectedVariantId,
                  builder: (context, variantId, _) {
                    return WishlistFavoriteButton(
                      productId: product.id,
                      productVariantId: product.variants.isEmpty
                          ? null
                          : variantId,
                    );
                  },
                ),
              ],
            ),
            const Gap(6),
            Text(
              product.description.localized(languageCode),
              style: AppFont.font14W500Grey2.copyWith(color: AppColor.textGrey),
            ),
            if (variants.isNotEmpty) ...[
              const Gap(14),
              Text('Variants'.tr, style: AppFont.font16W700Primary),
              const Gap(10),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: variants.length,
                  separatorBuilder: (_, __) => const Gap(8),
                  itemBuilder: (context, index) {
                    final variant = variants[index];
                    return _VariantTile(
                      label: variant.name.localized(languageCode),
                      priceText:
                          '${variant.price.toStringAsFixed(2)} ${'EGP'.tr}',
                      selected: variantId == variant.id,
                      enabled: !variant.isOutOfStock,
                      onTap: () {
                        selectedVariantId.value = variant.id;
                        final url = variant.imageUrl;
                        if (url == null || url.isEmpty) return;
                        final galleryIndex = galleryUrls.indexOf(url);
                        if (galleryIndex >= 0) {
                          selectedGalleryIndex.value = galleryIndex;
                        }
                      },
                    );
                  },
                ),
              ),
            ],
            const Gap(14),
            Row(
              children: [
                Builder(
                  builder: (context) {
                    final prices = priceDisplay(product, selectedVariant);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          prices.current,
                          style: AppFont.font20W700Black.copyWith(
                            color: const Color(0xFFFFB36D),
                          ),
                        ),
                        if (prices.original != null) ...[
                          const Gap(8),
                          Text(
                            prices.original!,
                            style: AppFont.font14W500Grey2.copyWith(
                              color: AppColor.textGrey,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: AppColor.priceStrikeRed,
                            ),
                          ),
                        ],
                        if (prices.badge != null) ...[
                          const Gap(8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.priceStrikeRed.withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              prices.badge!,
                              style: AppFont.font12W600Primary.copyWith(
                                color: AppColor.priceStrikeRed,
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const Spacer(),
                ValueListenableBuilder<int>(
                  valueListenable: qty,
                  builder: (context, value, _) {
                    final canDec = value > 1 || isInCart;
                    return _QtyStepper(
                      qty: value,
                      showDelete: isInCart && value <= 1,
                      isIncrementing: isIncrementingQty,
                      isDecrementing: isDecrementingQty,
                      onDec: qtyEnabled && canDec
                          ? () => onQtyChanged(value - 1)
                          : null,
                      onInc: qtyEnabled
                          ? () => onQtyChanged(value + 1)
                          : null,
                    );
                  },
                ),
              ],
            ),
            if (product.additions.isNotEmpty) ...[
              const Gap(16),
              Text('Additions'.tr, style: AppFont.font16W700Primary),
              const Gap(10),
              ValueListenableBuilder<Set<int>>(
                valueListenable: selectedAdditionIds,
                builder: (context, selectedIds, _) {
                  return Column(
                    children: [
                      for (var i = 0; i < product.additions.length; i++) ...[
                        if (i > 0) const Gap(10),
                        _AddonTile(
                          addition: product.additions[i],
                          languageCode: languageCode,
                          selected:
                              selectedIds.contains(product.additions[i].id),
                          onToggle: () {
                            final next = Set<int>.from(selectedIds);
                            if (next.contains(product.additions[i].id)) {
                              next.remove(product.additions[i].id);
                            } else {
                              next.add(product.additions[i].id);
                            }
                            selectedAdditionIds.value = next;
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

class _VariantTile extends StatelessWidget {
  const _VariantTile({
    required this.label,
    required this.priceText,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String priceText;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF7EFFF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColor.primary : AppColor.lightBorder,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppFont.font14W700Black.copyWith(
                color: enabled ? AppColor.textDark : AppColor.textGrey,
              ),
            ),
            const Gap(4),
            Text(
              priceText,
              style: AppFont.font12w500Grey2.copyWith(
                color: const Color(0xFFFFB36D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF2F2F2),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: AppColor.textDark),
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            top: 0,
            end: 0,
            start: 0,
            height: 150,
            child: SvgPicture.asset(
              AppAssets.productBack,
              fit: BoxFit.fill,
            ),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: ImageOrSvg(
                imagePath,
                width: 190,
                height: 190,
                fit: BoxFit.cover,
                pickImageOnNull: true,
                magnifier: true,
                assetImageOnNull: AppAssets.homeCategoryFood,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryThumbnails extends StatelessWidget {
  const _GalleryThumbnails({
    required this.images,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> images;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 4),
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const Gap(10),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: selected
                        ? AppColor.primary.withAlpha(120)
                        : Colors.transparent,
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
                border: Border.all(
                  color: selected ? AppColor.primary : Colors.transparent,
                  width: 1.4,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ImageOrSvg(
                  images[index],
                  height: 72,
                  width: 72,
                  fit: BoxFit.cover,
                  pickImageOnNull: true,
                  assetImageOnNull: AppAssets.homeCategoryFood,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.qty,
    required this.onDec,
    required this.onInc,
    this.showDelete = false,
    this.isIncrementing = false,
    this.isDecrementing = false,
  });

  final int qty;
  final VoidCallback? onDec;
  final VoidCallback? onInc;
  final bool showDelete;
  final bool isIncrementing;
  final bool isDecrementing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EFFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDecrementing)
            SizedBox(
              width: 24,
              height: 24,
              child: LoadingWidget(
                size: 14,
                color: showDelete
                    ? AppColor.priceStrikeRed
                    : AppColor.primary,
              ),
            )
          else
            _QtyButton(
              icon: showDelete
                  ? Icons.delete_outline_rounded
                  : Icons.remove_rounded,
              color: showDelete
                  ? AppColor.priceStrikeRed
                  : AppColor.primary,
              onTap: onDec,
            ),
          const Gap(12),
          Text('$qty', style: AppFont.font14W700Black),
          const Gap(12),
          if (isIncrementing)
            const SizedBox(
              width: 24,
              height: 24,
              child: LoadingWidget(size: 14),
            )
          else
            _QtyButton(icon: Icons.add_rounded, onTap: onInc),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final activeColor = color ?? AppColor.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 24,
        height: 24,
        child: Icon(
          icon,
          size: 18,
          color: enabled ? activeColor : activeColor.withAlpha(100),
        ),
      ),
    );
  }
}

class _AddonTile extends StatelessWidget {
  const _AddonTile({
    required this.addition,
    required this.languageCode,
    required this.selected,
    required this.onToggle,
  });

  final ProductAdditionEntity addition;
  final String languageCode;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? AppColor.primary : AppColor.lightBorder,
          width: selected ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: ImageOrSvg(
              null,
              width: 46,
              height: 46,
              fit: BoxFit.cover,
              pickImageOnNull: true,
              assetImageOnNull: AppAssets.homeCategoryFood,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  addition.name.localized(languageCode),
                  style: AppFont.font14W700Black,
                ),
                const Gap(6),
                Text(
                  '${addition.price.toStringAsFixed(2)} ${'EGP'.tr}',
                  style: AppFont.font14W700Black.copyWith(
                    color: const Color(0xFFFFB36D),
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          Container(
            decoration: BoxDecoration(
              gradient: AppColor.defaultPrimaryGradient2,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selected ? Icons.check_rounded : Icons.add_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const Gap(8),
                      Text(
                        selected ? 'Added'.tr : 'Add'.tr,
                        style: AppFont.font14W700White,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionsBar extends StatelessWidget {
  const _BottomActionsBar({
    required this.isAdding,
    required this.isInCart,
    required this.onAddToCart,
    required this.onCompleteOrder,
  });

  final bool isAdding;
  final bool isInCart;
  final VoidCallback onAddToCart;
  final VoidCallback onCompleteOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isAdding ? null : onAddToCart,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isInCart
                          ? AppColor.primary.withAlpha(180)
                          : AppColor.primary,
                      width: 1.4,
                    ),
                    backgroundColor:
                        isInCart ? AppColor.primary.withAlpha(20) : null,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: isAdding
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: LoadingWidget(size: 18),
                        )
                      : Icon(
                          isInCart
                              ? Icons.shopping_cart_rounded
                              : Icons.lock_outline_rounded,
                          color: AppColor.primary,
                        ),
                  label: Text(
                    (isInCart ? 'In cart' : 'Add to cart').tr,
                    style: AppFont.font16W700Primary,
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColor.defaultPrimaryGradient2,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: onCompleteOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.playlist_add_check_rounded,
                        color: Colors.white),
                    label: Text(
                      'Complete order'.tr,
                      style: AppFont.font16W600NearlyWhite.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
