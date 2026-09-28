import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/cart/data/models/cart_item_model.dart';
import 'package:heraj/features/cart/domain/entities/cart_summary_entity.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/cart/presentation/managers/cart_actions_mixin.dart';
import 'package:heraj/features/cart/presentation/managers/cart_screen_actions_mixin.dart';
import 'package:heraj/features/cart/presentation/managers/fetch_cart_provider.dart';
import 'package:heraj/features/cart/presentation/view/widgets/cart_empty.dart';
import 'package:heraj/features/cart/presentation/view/widgets/create_bundle_order_slider.dart';
import 'package:heraj/helper/extensions/adaptive_view.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:heraj/ui/ui.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  static String _formatMoney(double amount) {
    final text =
        amount % 1 == 0 ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2);
    return '$text ${'EGP'.tr}';
  }

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen>
    with CartScreenActionsMixin {
  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(fetchCartProvider);
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final isCreatingBundle = ref.watch(
        isLoadingProvider(CartScreenActionsMixin.createBundleLoadingKey));
    final isViewingBundle = ref
        .watch(isLoadingProvider(CartScreenActionsMixin.viewBundleLoadingKey));
    final isPuttingInBundle = ref
        .watch(isLoadingProvider(CartScreenActionsMixin.putInBundleLoadingKey));

    return Scaffold(
      backgroundColor: AppColor.pageBackgroundGrey,
      bottomSheet: cartAsync.maybeWhen(
        data: (cart) {
          if (cart.isEmpty && !cart.hasBundleOrder) return null;
          if (cart.isEmpty && cart.hasBundleOrder) {
            return _ActiveBundleOrderBottomSheet(
              isViewingBundle: isViewingBundle,
              onViewBundleOrder: () => viewActiveBundleOrder(
                code: cart.bundleOrderCode,
              ),
            );
          }
          return _CartCheckoutBottomSheet(
            totalText: CartScreen._formatMoney(cart.summary.totalWithoutShipping),
            hasBundleOrder: cart.hasBundleOrder,
            isCreatingBundle: isCreatingBundle,
            isPuttingInBundle: isPuttingInBundle,
            onCreateBundle: createBundleOrderFromSwipe,
            onPutInBundle: () => putCartInBundle(code: cart.bundleOrderCode),
            onCompleteOrder: () => Get.toNamed(
              '/checkout',
              arguments: cart,
            ),
          );
        },
        orElse: () => null,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: AppColor.textDark,
                      ),
                    ),
                  ),
                  Text(
                    'Cart'.tr,
                    style: AppFont.font18W700Black.copyWith(
                      color: AppColor.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  cartAsync.maybeWhen(
                    data: (cart) {
                      if (cart.isEmpty) {
                        return const SizedBox(width: 24, height: 24);
                      }
                      final canJoinBundle =
                          !cart.hasBundleOrder && !isPuttingInBundle;
                      return InkWell(
                        onTap: canJoinBundle
                            ? () => putCartInBundle(code: cart.bundleOrderCode)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                          child: isPuttingInBundle
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: LoadingWidget(size: 18),
                                )
                              : Text(
                                  'Join bundle order'.tr,
                                  style: AppFont.font12W600Primary.copyWith(
                                    color: canJoinBundle
                                        ? AppColor.primary
                                        : AppColor.primary.withAlpha(90),
                                  ),
                                ),
                        ),
                      );
                    },
                    orElse: () => const SizedBox(width: 24, height: 24),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(fetchCartProvider);
                  await ref.read(fetchCartProvider.future);
                },
                child: cartAsync.customWhen(
                  ref: ref,
                  refreshable: fetchCartProvider.future,
                  skipLoadingOnRefresh: true,
                  skipLoadingOnReload: true,
                  loading: () => const PageLoadingWidget(),
                  data: (cart) {
                    if (cart.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.65,
                            child: const CartEmpty(),
                          ),
                          if (cart.hasBundleOrder)
                            SizedBox(
                              height:
                                  100 + MediaQuery.of(context).padding.bottom,
                            ),
                        ],
                      );
                    }

                    final productItems = cart.productItems;
                    final addonItems = cart.addonItems;

                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        12,
                        10,
                        12,
                        (cart.hasBundleOrder ? 240 : 210) +
                            MediaQuery.of(context).padding.bottom,
                      ),
                      children: [
                        for (var i = 0; i < productItems.length; i++) ...[
                          if (i > 0) const Gap(15),
                          _CartLineCard(
                            key: ValueKey(productItems[i].id),
                            item: productItems[i],
                            languageCode: languageCode,
                          ),
                        ],
                        if (addonItems.isNotEmpty) ...[
                          const Gap(16),
                          Text(
                            'Addons'.tr,
                            style: AppFont.font16W700Black.copyWith(
                              color: AppColor.textDark,
                            ),
                          ),
                          const Gap(8),
                          for (var i = 0; i < addonItems.length; i++) ...[
                            if (i > 0) const Gap(8),
                            _CartAddonRow(
                              key: ValueKey(addonItems[i].id),
                              item: addonItems[i],
                              languageCode: languageCode,
                              priceText: CartScreen._formatMoney(
                                addonItems[i].lineTotal,
                              ),
                            ),
                          ],
                        ],
                        const Gap(16),
                        _CartOrderSummary(
                          summary: cart.summary,
                          money: CartScreen._formatMoney,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveBundleOrderBottomSheet extends StatelessWidget {
  const _ActiveBundleOrderBottomSheet({
    required this.isViewingBundle,
    required this.onViewBundleOrder,
  });

  final bool isViewingBundle;
  final VoidCallback onViewBundleOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: context.safeAreaBottom + 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: CustomFilledButton(
            text: 'View active bundle order'.tr,
            gradient: AppColor.defaultPrimaryGradient2,
            radius: 18,
            isLoading: isViewingBundle,
            onPressed: onViewBundleOrder,
          ),
        ),
      ),
    );
  }
}

class _CartCheckoutBottomSheet extends StatelessWidget {
  const _CartCheckoutBottomSheet({
    required this.totalText,
    required this.hasBundleOrder,
    required this.isCreatingBundle,
    required this.isPuttingInBundle,
    required this.onCreateBundle,
    required this.onPutInBundle,
    required this.onCompleteOrder,
  });

  final String totalText;
  final bool hasBundleOrder;
  final bool isCreatingBundle;
  final bool isPuttingInBundle;
  final VoidCallback onCreateBundle;
  final VoidCallback onPutInBundle;
  final VoidCallback onCompleteOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: context.safeAreaBottom + 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasBundleOrder) ...[
                CustomFilledButton(
                  text: 'Complete order'.tr,
                  gradient: AppColor.defaultPrimaryGradient2,
                  radius: 18,
                  onPressed: onCompleteOrder,
                ),
                const Gap(12),
              ] else ...[
                CreateBundleOrderSlider(
                  isLoading: isCreatingBundle,
                  onCompleted: onCreateBundle,
                ),
                const Gap(12),
              ],
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cart order total'.tr,
                          style: AppFont.font12w500Grey2.copyWith(
                            color: AppColor.textBodySecondary,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          totalText,
                          style: AppFont.font18W700Black.copyWith(
                            color: AppColor.guestOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: hasBundleOrder
                        ? CustomFilledButton(
                            text: 'Put in bundle'.tr,
                            gradient: AppColor.defaultPrimaryGradient2,
                            radius: 18,
                            isLoading: isPuttingInBundle,
                            onPressed: isPuttingInBundle ? null : onPutInBundle,
                          )
                        : CustomFilledButton(
                            text: 'Complete order'.tr,
                            gradient: AppColor.defaultPrimaryGradient2,
                            radius: 18,
                            onPressed: onCompleteOrder,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartLineCard extends ConsumerStatefulWidget {
  const _CartLineCard({
    super.key,
    required this.item,
    required this.languageCode,
  });

  final CartItemModel item;
  final String languageCode;

  @override
  ConsumerState<_CartLineCard> createState() => _CartLineCardState();
}

class _CartLineCardState extends ConsumerState<_CartLineCard>
    with CartActionsMixin {
  String get _addLoadingKey => 'addCartQty_${widget.item.id}';
  String get _qtyLoadingKey => 'updateCartQty_${widget.item.id}';
  String get _removeLoadingKey => 'removeCart_${widget.item.id}';

  Future<void> _addOneMore() async {
    await addProductToCart(
      productId: widget.item.productId,
      productVariantId: widget.item.productVariantId,
      quantity: 1,
      loadingKey: _addLoadingKey,
      showSnackBar: false,
    );
  }

  Future<void> _decrementQuantity() async {
    if (widget.item.quantity <= 1) return;
    await addProductToCart(
      productId: widget.item.productId,
      productVariantId: widget.item.productVariantId,
      quantity: -1,
      loadingKey: _qtyLoadingKey,
      showSnackBar: false,
    );
  }

  Future<bool> _removeItem() {
    return removeCartItem(
      cartItemId: widget.item.id,
      loadingKey: _removeLoadingKey,
      invalidateOnSuccess: false,
      showSnackBar: false,
    );
  }

  Future<void> _removeItemFromIcon() async {
    await removeCartItem(
      cartItemId: widget.item.id,
      loadingKey: _removeLoadingKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final title = item.product?.name.localized(widget.languageCode) ?? '';
    final subtitle = item.variant?.name.localized(widget.languageCode) ?? '';
    final imageUrl = item.variant?.imageUrl ?? item.product?.thumbnailImageUrl;
    final isAdding = ref.watch(isLoadingProvider(_addLoadingKey));
    final isUpdating = ref.watch(isLoadingProvider(_qtyLoadingKey));
    final isRemoving = ref.watch(isLoadingProvider(_removeLoadingKey));
    final isBusy = isAdding || isUpdating || isRemoving;

    return Dismissible(
      key: ValueKey('cart_item_${item.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        if (isBusy) return false;
        return _removeItem();
      },
      onDismissed: (_) {
        ref.invalidate(fetchCartProvider);
        UIHelper.showGlobalSnackBar(text: 'Removed from cart'.tr);
      },
      background: Container(
        decoration: BoxDecoration(
          color: AppColor.priceStrikeRed,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.cartCardBorder),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ImageOrSvg(
                imageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                pickImageOnNull: true,
                assetImageOnNull: AppAssets.homeCategoryFood,
              ),
            ),
            const Gap(8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.font14W500Black.copyWith(
                        color: AppColor.gray900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const Gap(4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.font12w500Grey2.copyWith(
                          color: AppColor.textBodyTertiary,
                          fontSize: 10,
                          height: 15 / 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    const Gap(4),
                    _CartItemPrice(item: item),
                  ],
                ),
              ),
            ),
            const Gap(8),
            _CartQtyStepper(
              quantity: item.quantity,
              isBusy: isBusy,
              isRemoving: isRemoving,
              isDecrementing: isUpdating,
              isAdding: isAdding,
              onDelete: isBusy ? null : _removeItemFromIcon,
              onDecrement: isBusy ? null : _decrementQuantity,
              onIncrement: isBusy ? null : _addOneMore,
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemPrice extends StatelessWidget {
  const _CartItemPrice({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final showOriginal = item.hasOffer &&
        item.originalUnitPrice > 0 &&
        item.originalUnitPrice > item.unitPrice;

    return Row(
      children: [
        if (showOriginal) ...[
          Text(
            CartScreen._formatMoney(item.originalUnitPrice),
            style: AppFont.font12w500Grey2.copyWith(
              color: AppColor.textBodyTertiary,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColor.textBodyTertiary,
            ),
          ),
          const Gap(6),
        ],
        Text(
          CartScreen._formatMoney(item.unitPrice),
          style: AppFont.font14W500Black.copyWith(
            color: AppColor.guestOrange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CartAddonRow extends ConsumerStatefulWidget {
  const _CartAddonRow({
    super.key,
    required this.item,
    required this.languageCode,
    required this.priceText,
  });

  final CartItemModel item;
  final String languageCode;
  final String priceText;

  @override
  ConsumerState<_CartAddonRow> createState() => _CartAddonRowState();
}

class _CartAddonRowState extends ConsumerState<_CartAddonRow>
    with CartActionsMixin {
  String get _removeLoadingKey => 'removeCart_${widget.item.id}';

  Future<void> _removeItem() async {
    await removeCartItem(
      cartItemId: widget.item.id,
      loadingKey: _removeLoadingKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final addonTitle = item.addonName.localized(widget.languageCode);
    final title = addonTitle.isNotEmpty ? addonTitle : 'Custom addon'.tr;
    final vendorName = item.vendor?.name.trim() ?? '';
    final subtitle = vendorName.isNotEmpty
        ? 'Addon from @vendor'.trParams({'vendor': vendorName})
        : 'Custom addon'.tr;
    final isBusy = ref.watch(isLoadingProvider(_removeLoadingKey));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.cartCardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.font14W500Black.copyWith(
                    color: AppColor.gray900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.font12w500Grey2.copyWith(
                    color: AppColor.textBodyTertiary,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Gap(4),
                Text(
                  widget.priceText,
                  style: AppFont.font14W500Black.copyWith(
                    color: AppColor.guestOrange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
          InkWell(
            onTap: isBusy ? null : _removeItem,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: isBusy
                  ? const LoadingWidget(
                      size: 18,
                      color: AppColor.priceStrikeRed,
                    )
                  : const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColor.priceStrikeRed,
                      size: 22,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartQtyStepper extends StatelessWidget {
  const _CartQtyStepper({
    required this.quantity,
    required this.isBusy,
    this.isRemoving = false,
    this.isDecrementing = false,
    this.isAdding = false,
    required this.onDelete,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final bool isBusy;
  final bool isRemoving;
  final bool isDecrementing;
  final bool isAdding;
  final VoidCallback? onDelete;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    final canDecrement = quantity > 1;
    final leftLoading = canDecrement ? isDecrementing : isRemoving;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.primary.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leftLoading)
            SizedBox(
              width: 24,
              height: 24,
              child: LoadingWidget(
                size: 14,
                color:
                    canDecrement ? AppColor.primary : AppColor.priceStrikeRed,
              ),
            )
          else
            _CartQtyButton(
              icon: canDecrement
                  ? Icons.remove_rounded
                  : Icons.delete_outline_rounded,
              color: canDecrement ? AppColor.primary : AppColor.priceStrikeRed,
              onTap: canDecrement ? onDecrement : onDelete,
            ),
          SizedBox(
            width: 28,
            child: Center(
              child: isBusy && !leftLoading && !isAdding
                  ? const LoadingWidget(size: 14)
                  : Text(
                      '$quantity',
                      style: AppFont.font14W700Black.copyWith(
                        color: AppColor.primary,
                      ),
                    ),
            ),
          ),
          if (isAdding)
            const SizedBox(
              width: 24,
              height: 24,
              child: LoadingWidget(size: 14),
            )
          else
            _CartQtyButton(
              icon: Icons.add_rounded,
              onTap: onIncrement,
            ),
        ],
      ),
    );
  }
}

class _CartQtyButton extends StatelessWidget {
  const _CartQtyButton({
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
          color: enabled ? activeColor : activeColor.withAlpha(90),
        ),
      ),
    );
  }
}

/// Cart totals: order, offer discount when one is applied, and service fee.
class _CartOrderSummary extends StatelessWidget {
  const _CartOrderSummary({
    required this.summary,
    required this.money,
  });

  final CartSummaryEntity summary;
  final String Function(double) money;

  @override
  Widget build(BuildContext context) {
    final offerDiscount = summary.appliedOffers.isNotEmpty
        ? summary.offerSavingsTotal
        : (summary.hasOffer ? summary.productDiscount : 0.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECECEC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cart order summary'.tr,
            style: AppFont.font16W700Black.copyWith(
              color: AppColor.textDark,
            ),
          ),
          const Gap(12),
          _CartSummaryRow(
            label: 'Cart order'.tr,
            value: money(summary.subtotal),
          ),
          if (offerDiscount > 0) ...[
            const Gap(8),
            _CartSummaryRow(
              label: 'Cart discount'.tr,
              value: '- ${money(offerDiscount)}',
              valueColor: AppColor.priceStrikeRed,
            ),
          ],
          const Gap(8),
          _CartSummaryRow(
            label: 'Cart service fee'.tr,
            value: money(summary.serviceFee),
          ),
          const Gap(10),
          const Divider(height: 1),
          const Gap(10),
          _CartSummaryRow(
            label: 'Cart order total'.tr,
            value: money(summary.totalWithoutShipping),
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _CartSummaryRow extends StatelessWidget {
  const _CartSummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: emphasize
                ? AppFont.font16W700Black
                : AppFont.font14W500Black.copyWith(
                    color: AppColor.textBodySecondary,
                  ),
          ),
        ),
        Text(
          value,
          style: emphasize
              ? AppFont.font16W700Black.copyWith(color: AppColor.guestOrange)
              : AppFont.font14W700Black.copyWith(
                  color: valueColor ?? AppColor.textDark,
                ),
        ),
      ],
    );
  }
}
