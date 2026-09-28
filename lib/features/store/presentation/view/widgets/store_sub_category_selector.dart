import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/categories/data/models/category_model.dart';
import 'package:heraj/features/categories/presentation/managers/fetch_categories_provider.dart';
import 'package:heraj/features/store/presentation/manager/store_provider.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';

class StoreCategorySelector extends ConsumerWidget {
  const StoreCategorySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorTypeId = ref.watch(storeSelectedCategoryIdProvider);
    if (vendorTypeId <= 0) {
      return const SizedBox.shrink();
    }

    final categoriesAsync =
        ref.watch(fetchCategoriesByVendorTypeProvider(vendorTypeId));
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return categoriesAsync.customWhen(
      ref: ref,
      refreshable: fetchCategoriesByVendorTypeProvider(vendorTypeId).future,
      loading: () => SizedBox(
        height: 92,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemCount: 4,
          separatorBuilder: (_, __) => const Gap(8),
          itemBuilder: (_, __) => ShimmerEffect(
            enable: true,
            child: Container(
              width: 84,
              decoration: BoxDecoration(
                color: const Color(0xFFECECEC),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (categories) {
        if (categories.isEmpty) return const SizedBox.shrink();
        final selectedSubId = ref.watch(storeSelectedSubCategoryIdProvider);
        return SizedBox(
          height: 92,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _AllCategoryCard(
                  selected: selectedSubId == 0,
                  onTap: () => ref
                      .read(storeSelectedSubCategoryIdProvider.notifier)
                      .state = 0,
                ),
                for (final category in categories) ...[
                  const Gap(8),
                  _CategoryCard(
                    category: category,
                    selected: selectedSubId == category.id,
                    languageCode: languageCode,
                    onTap: () => ref
                        .read(storeSelectedSubCategoryIdProvider.notifier)
                        .state = category.id,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AllCategoryCard extends StatelessWidget {
  const _AllCategoryCard({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 84,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE2C8F7) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.lightBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.grid_view_rounded,
              size: 34,
              color: AppColor.primary,
            ),
            const Gap(6),
            Text(
              'All'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppFont.font14W600Black.copyWith(
                color: AppColor.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.selected,
    required this.languageCode,
    required this.onTap,
  });

  final CategoryModel category;
  final bool selected;
  final String languageCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 84,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE2C8F7) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.lightBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: ImageOrSvg(
                category.imageUrl,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                pickImageOnNull: true,
                assetImageOnNull: AppAssets.homeCategoryFood,
              ),
            ),
            const Gap(6),
            Text(
              category.name.localized(languageCode),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppFont.font14W600Black.copyWith(
                color: AppColor.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
