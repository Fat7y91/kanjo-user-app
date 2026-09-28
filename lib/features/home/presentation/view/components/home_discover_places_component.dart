import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/home/presentation/managers/home_vendors_provider.dart';
import 'package:heraj/features/root/controller/root_controller.dart';
import 'package:heraj/features/store/presentation/view/store_details_screen.dart';
import 'package:heraj/features/store/presentation/view/widgets/offline_store_caution_sheet.dart';
import 'package:heraj/features/vendor/data/models/vendor_model.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';

class HomeDiscoverPlacesComponent extends ConsumerWidget {
  const HomeDiscoverPlacesComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeVendorsProvider);
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return state.customWhen(
      ref: ref,
      refreshable: homeVendorsProvider.future,
      loading: () => const _HomeVendorsShimmer(),
      data: (vendors) {
        if (vendors.isEmpty) return const SizedBox.shrink();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Discover places this month'.tr,
                      style: AppFont.font16W600Black.copyWith(
                        color: AppColor.textDark,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => ref
                        .read(rootIndex.notifier)
                        .setSelectedIndex(NavBarItem.shipments.index),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'View all'.tr,
                            style: AppFont.font12w500Grey2.copyWith(
                              color: AppColor.primary,
                            ),
                          ),
                          const Gap(4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: AppColor.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  for (var i = 0; i < vendors.length; i++) ...[
                    if (i > 0) const Gap(10),
                    SizedBox(
                      width: 170,
                      child: _HomeVendorCard(
                        vendor: vendors[i],
                        languageCode: languageCode,
                        onTap: () => _openStore(context, vendors[i]),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Future<void> _openStore(BuildContext context, VendorModel vendor) async {
    if (isVendorOffline(vendor)) {
      final shouldContinue = await showOfflineStoreCautionSheet(context);
      if (!shouldContinue || !context.mounted) return;
    }
    Get.to(() => StoreDetailsScreen(vendor: vendor));
  }
}

class _HomeVendorCard extends StatelessWidget {
  const _HomeVendorCard({
    required this.vendor,
    required this.languageCode,
    required this.onTap,
  });

  final VendorModel vendor;
  final String languageCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ratingText = vendor.ratingSummary.average == null
        ? '-'
        : vendor.rating.toStringAsFixed(1);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: double.infinity,
              height: 120,
              child: ImageOrSvg(
                vendor.imageUrl.isEmpty ? null : vendor.imageUrl,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                pickImageOnNull: true,
                assetImageOnNull: AppAssets.homeCategoryFood,
              ),
            ),
          ),
          const Gap(8),
          Text(
            vendor.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFont.font16W600Black.copyWith(
              color: AppColor.textDark,
            ),
          ),
          const Gap(4),
          Text(
            vendor.type.name.localized(languageCode),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFont.font12w400Black.copyWith(
              color: AppColor.textGrey,
            ),
          ),
          const Gap(4),
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: AppColor.gold),
              const Gap(4),
              Text(
                ratingText,
                style: AppFont.font12w400Black.copyWith(
                  color: AppColor.textGrey,
                ),
              ),
              const Gap(4),
              Flexible(
                child: Text(
                  '• ${vendor.reviewsCount} ${'reviews'.tr}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.font12w400Black.copyWith(
                    color: AppColor.textGrey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeVendorsShimmer extends StatelessWidget {
  const _HomeVendorsShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ShimmerEffect(
                  enable: true,
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const Gap(24),
              ShimmerEffect(
                enable: true,
                child: Container(
                  width: 64,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(
              4,
              (index) => Padding(
                padding: EdgeInsetsDirectional.only(end: index == 3 ? 0 : 10),
                child: ShimmerEffect(
                  enable: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 170,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const Gap(8),
                      Container(
                        width: 120,
                        height: 14,
                        color: Colors.white,
                      ),
                      const Gap(6),
                      Container(
                        width: 80,
                        height: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
