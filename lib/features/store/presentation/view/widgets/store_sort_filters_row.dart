import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/store/presentation/manager/store_provider.dart';

class StoreSortFiltersRow extends StatelessWidget {
  const StoreSortFiltersRow({
    super.key,
    required this.sortType,
    required this.offersSelected,
    required this.featuredSelected,
    required this.onSelectSort,
    required this.onToggleOffers,
    required this.onToggleFeatured,
  });

  final StoreSortType sortType;
  final bool offersSelected;
  final bool featuredSelected;
  final ValueChanged<StoreSortType> onSelectSort;
  final VoidCallback onToggleOffers;
  final VoidCallback onToggleFeatured;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SizedBox(
        height: 40,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _StoreSortChip(
                label: 'Sort by'.tr,
                selected: false,
                onTap: () {},
                trailing: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColor.textGrey,
                ),
              ),
              const Gap(8),
              _StoreSortChip(
                label: 'Offers'.tr,
                selected: offersSelected,
                onTap: onToggleOffers,
              ),
              const Gap(8),
              _StoreSortChip(
                label: 'Featured'.tr,
                selected: featuredSelected,
                onTap: onToggleFeatured,
              ),
              const Gap(8),
              _StoreSortChip(
                label: 'Newest places'.tr,
                selected: sortType == StoreSortType.nearby,
                onTap: () => onSelectSort(StoreSortType.nearby),
              ),
              const Gap(8),
              _StoreSortChip(
                label: 'Least'.tr,
                selected: sortType == StoreSortType.topRated,
                onTap: () => onSelectSort(StoreSortType.topRated),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreSortChip extends StatelessWidget {
  const _StoreSortChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColor.primary : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColor.lightBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppFont.font16W500Black.copyWith(
                color: selected ? Colors.white : AppColor.textDark,
                fontSize: 14,
              ),
            ),
            if (trailing != null) ...[
              const Gap(4),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
