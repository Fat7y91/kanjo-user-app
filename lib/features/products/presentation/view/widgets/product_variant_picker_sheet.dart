import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/products/domain/entities/product_variant_entity.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';

class ProductVariantPickerResult {
  const ProductVariantPickerResult({
    required this.variant,
    required this.quantity,
  });

  final ProductVariantEntity variant;
  final int quantity;
}

Future<ProductVariantPickerResult?> showProductVariantPickerSheet({
  required BuildContext context,
  required List<ProductVariantEntity> variants,
  required String languageCode,
  String? productImageUrl,
}) {
  final active = variants.where((v) => v.isActive).toList();
  final pool = active.isNotEmpty ? active : variants;

  return showModalBottomSheet<ProductVariantPickerResult>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ProductVariantPickerSheet(
      variants: pool,
      languageCode: languageCode,
      productImageUrl: productImageUrl,
    ),
  );
}

class _ProductVariantPickerSheet extends StatefulWidget {
  const _ProductVariantPickerSheet({
    required this.variants,
    required this.languageCode,
    this.productImageUrl,
  });

  final List<ProductVariantEntity> variants;
  final String languageCode;
  final String? productImageUrl;

  @override
  State<_ProductVariantPickerSheet> createState() =>
      _ProductVariantPickerSheetState();
}

class _ProductVariantPickerSheetState extends State<_ProductVariantPickerSheet> {
  late final ValueNotifier<int?> _selectedId;
  late final ValueNotifier<int> _qty;

  @override
  void initState() {
    super.initState();
    int? initialId;
    for (final variant in widget.variants) {
      if (!variant.isOutOfStock) {
        initialId = variant.id;
        break;
      }
    }
    initialId ??=
        widget.variants.isNotEmpty ? widget.variants.first.id : null;
    _selectedId = ValueNotifier(initialId);
    _qty = ValueNotifier(1);
    _selectedId.addListener(_resetQtyOnVariantChange);
  }

  void _resetQtyOnVariantChange() {
    _qty.value = 1;
  }

  @override
  void dispose() {
    _selectedId.removeListener(_resetQtyOnVariantChange);
    _selectedId.dispose();
    _qty.dispose();
    super.dispose();
  }

  ProductVariantEntity? _variantById(int? id) {
    if (id == null) return null;
    for (final variant in widget.variants) {
      if (variant.id == id) return variant;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.paddingOf(context).bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColor.grey1,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const Gap(16),
            Text(
              'Select variant'.tr,
              style: AppFont.font18W700Black,
              textAlign: TextAlign.center,
            ),
            const Gap(14),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.variants.length,
                separatorBuilder: (_, __) => const Gap(10),
                itemBuilder: (context, index) {
                  final variant = widget.variants[index];
                  final enabled = !variant.isOutOfStock;
                  return ValueListenableBuilder<int?>(
                    valueListenable: _selectedId,
                    builder: (context, selectedId, _) {
                      final selected = selectedId == variant.id;
                      return InkWell(
                        onTap: enabled
                            ? () => _selectedId.value = variant.id
                            : null,
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFF7EFFF)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? AppColor.primary
                                  : AppColor.lightBorder,
                              width: selected ? 1.4 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: ImageOrSvg(
                                  variant.imageUrl ?? widget.productImageUrl,
                                  width: 52,
                                  height: 52,
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
                                      variant.name
                                          .localized(widget.languageCode),
                                      style: AppFont.font14W700Black.copyWith(
                                        color: enabled
                                            ? AppColor.textDark
                                            : AppColor.textGrey,
                                      ),
                                    ),
                                    const Gap(4),
                                    Text(
                                      '${variant.price.toStringAsFixed(2)} ${'EGP'.tr}',
                                      style: AppFont.font12w500Grey2.copyWith(
                                        color: const Color(0xFFFFB36D),
                                      ),
                                    ),
                                    if (!enabled) ...[
                                      const Gap(2),
                                      Text(
                                        'Out of stock'.tr,
                                        style: AppFont.font12w500Grey2,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Icon(
                                selected
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                color: selected
                                    ? AppColor.primary
                                    : AppColor.lightBorder,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Gap(14),
            ValueListenableBuilder<int?>(
              valueListenable: _selectedId,
              builder: (context, selectedId, _) {
                final selected = _variantById(selectedId);
                final canAdjustQty =
                    selected != null && !selected.isOutOfStock;
                return Row(
                  children: [
                    Text(
                      'Quantity'.tr,
                      style: AppFont.font16W700Black,
                    ),
                    const Spacer(),
                    ValueListenableBuilder<int>(
                      valueListenable: _qty,
                      builder: (context, qty, _) {
                        return _VariantQtyStepper(
                          qty: qty,
                          enabled: canAdjustQty,
                          onDec: canAdjustQty && qty > 1
                              ? () => _qty.value = qty - 1
                              : null,
                          onInc: canAdjustQty
                              ? () => _qty.value = qty + 1
                              : null,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const Gap(16),
            ValueListenableBuilder<int?>(
              valueListenable: _selectedId,
              builder: (context, selectedId, _) {
                return ValueListenableBuilder<int>(
                  valueListenable: _qty,
                  builder: (context, qty, _) {
                    final selected = _variantById(selectedId);
                    final canAdd =
                        selected != null && !selected.isOutOfStock && qty > 0;
                    return CustomFilledButton(
                      text: 'Add to cart'.tr,
                      isValid: canAdd,
                      gradient: AppColor.defaultPrimaryGradient2,
                      onPressed: canAdd
                          ? () => Navigator.of(context).pop(
                                ProductVariantPickerResult(
                                  variant: selected,
                                  quantity: qty,
                                ),
                              )
                          : null,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _VariantQtyStepper extends StatelessWidget {
  const _VariantQtyStepper({
    required this.qty,
    required this.enabled,
    required this.onDec,
    required this.onInc,
  });

  final int qty;
  final bool enabled;
  final VoidCallback? onDec;
  final VoidCallback? onInc;

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
          _VariantQtyButton(
            icon: Icons.remove_rounded,
            onTap: enabled ? onDec : null,
          ),
          const Gap(12),
          Text('$qty', style: AppFont.font14W700Black),
          const Gap(12),
          _VariantQtyButton(
            icon: Icons.add_rounded,
            onTap: enabled ? onInc : null,
          ),
        ],
      ),
    );
  }
}

class _VariantQtyButton extends StatelessWidget {
  const _VariantQtyButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 24,
        height: 24,
        child: Icon(
          icon,
          size: 18,
          color: active ? AppColor.primary : AppColor.primary.withAlpha(90),
        ),
      ),
    );
  }
}
