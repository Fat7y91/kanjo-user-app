import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/vendor/data/models/vendor_model.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';

class StoreCard extends StatelessWidget {
  const StoreCard({
    super.key,
    required this.vendor,
    required this.languageCode,
    required this.onTap,
  });

  final VendorModel vendor;
  final String languageCode;
  final VoidCallback onTap;

  static const _offlineGreyscale = ColorFilter.matrix(<double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);

  @override
  Widget build(BuildContext context) {
    final ratingText = vendor.ratingSummary.average == null
        ? '-'
        : vendor.rating.toStringAsFixed(1);
    final isOffline = vendor.availabilityStatus.toLowerCase() == 'offline';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColor.lightBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: SizedBox(
                width: double.infinity,
                height: 140,
                child: _StoreCardImage(
                  vendor: vendor,
                  isOffline: isOffline,
                  colorFilter: isOffline ? _offlineGreyscale : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vendor.name, style: AppFont.font18W700Black),
                  const Gap(2),
                  Text(
                    vendor.type.name.localized(languageCode),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.font13W400Black
                        .copyWith(color: AppColor.textGrey),
                  ),
                  const Gap(6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColor.gold, size: 16),
                      const Gap(4),
                      Text(
                        ratingText,
                        style: AppFont.font14W500Black.copyWith(
                          color: AppColor.textGrey,
                        ),
                      ),
                      const Gap(6),
                      Text(
                        '• ${vendor.reviewsCount} ${'reviews'.tr}',
                        style: AppFont.font14W500Black.copyWith(
                          color: AppColor.textGrey,
                        ),
                      ),
                      const Gap(6),
                      Flexible(
                        child: Text(
                          '• ${vendor.availabilityStatus.replaceAll('_', ' ')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFont.font14W500Black.copyWith(
                            color: AppColor.textGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (vendor.distanceKm != null ||
                      vendor.deliveryFee != null) ...[
                    const Gap(6),
                    Row(
                      children: [
                        if (vendor.distanceKm != null) ...[
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColor.textGrey,
                          ),
                          const Gap(4),
                          Text(
                            '@km km'.trParams({
                              'km': _formatDistance(vendor.distanceKm!),
                            }),
                            style: AppFont.font14W500Black.copyWith(
                              color: AppColor.textGrey,
                            ),
                          ),
                        ],
                        if (vendor.distanceKm != null &&
                            vendor.deliveryFee != null)
                          const Gap(12),
                        if (vendor.deliveryFee != null) ...[
                          const Icon(
                            Icons.delivery_dining_outlined,
                            size: 16,
                            color: AppColor.textGrey,
                          ),
                          const Gap(4),
                          Flexible(
                            child: Text(
                              '${_formatFee(vendor.deliveryFee!)} ${'EGP'.tr}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFont.font14W500Black.copyWith(
                                color: AppColor.textGrey,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  const Gap(8),
                  VendorStatusChips(vendor: vendor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VendorStatusChips extends StatelessWidget {
  const VendorStatusChips({super.key, required this.vendor});

  final VendorModel vendor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _StatusChip(
          label: vendor.isAcceptingOrders
              ? 'Accepting orders'.tr
              : 'Not accepting orders'.tr,
          foreground: vendor.isAcceptingOrders
              ? const Color(0xFF1C622E)
              : const Color(0xFFB42318),
          background: vendor.isAcceptingOrders
              ? const Color(0xFFCBE3BF)
              : const Color(0xFFFFE0E0),
        ),
        if (vendor.pricesIncludeVat)
          _StatusChip(
            label: 'Prices include VAT'.tr,
            foreground: AppColor.textDark,
            background: const Color(0xFFF2F2F2),
          ),
        if (vendor.busyLateOrderDelayMinutes > 0)
          _StatusChip(
            label: 'Busy · +@min min'.trParams({
              'min': '${vendor.busyLateOrderDelayMinutes}',
            }),
            foreground: const Color(0xFF9A6700),
            background: const Color(0xFFFFF1C2),
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppFont.font12w400Black.copyWith(
          color: foreground,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StoreCardImage extends StatelessWidget {
  const _StoreCardImage({
    required this.vendor,
    required this.isOffline,
    this.colorFilter,
  });

  final VendorModel vendor;
  final bool isOffline;
  final ColorFilter? colorFilter;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ImageFiltered(
          imageFilter: colorFilter != null
              ? ImageFilter.blur(sigmaX: 5, sigmaY: 5)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: ImageOrSvg(
            vendor.imageUrl.isEmpty ? null : vendor.imageUrl,
            width: double.infinity,
            height: 140,
            fit: BoxFit.cover,
            pickImageOnNull: true,
            assetImageOnNull: AppAssets.homeCategoryFood,
          ),
        ),
        if (isOffline)
        Center(
          child: Text(
            "offline".tr,
            style: AppFont.font18W700Black.copyWith(
              color: AppColor.textGrey.withAlpha(200),
            ),
          ),
        ),
      ],
    );
  }
}

class StoreCardPlaceholder extends StatelessWidget {
  const StoreCardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.lightBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: const BoxDecoration(
              color: Color(0xFFECECEC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 18,
                  width: 160,
                  color: const Color(0xFFECECEC),
                ),
                const Gap(8),
                Container(
                  height: 12,
                  width: 100,
                  color: const Color(0xFFECECEC),
                ),
                const Gap(10),
                Container(
                  height: 12,
                  width: 180,
                  color: const Color(0xFFECECEC),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDistance(double km) {
  if (km >= 10) return km.toStringAsFixed(0);
  if (km >= 1) return km.toStringAsFixed(1);
  return km.toStringAsFixed(2);
}

String _formatFee(double fee) {
  if (fee == fee.roundToDouble()) return fee.toStringAsFixed(0);
  return fee.toStringAsFixed(2);
}
