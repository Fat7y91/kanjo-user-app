import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/services/presentation/managers/services_provider.dart';
import 'package:heraj/features/store/presentation/manager/store_provider.dart';
import 'package:heraj/features/store/presentation/view/widgets/store_card.dart';
import 'package:heraj/features/vendor/data/models/vendor_type_model.dart';
import 'package:heraj/features/vendor/presentation/managers/fetch_vendor_types_provider.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';

class StoreVendorTypeSelector extends ConsumerWidget {
  const StoreVendorTypeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(fetchVendorTypesProvider);
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return typesAsync.customWhen(
      ref: ref,
      refreshable: fetchVendorTypesProvider.future,
      loading: () => SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemBuilder: (_, __) => const ShimmerEffect(
            enable: true,
            child: StoreCardPlaceholder(),
          ),
          separatorBuilder: (_, __) => const Gap(8),
          itemCount: 4,
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (types) {
        final storeTypes =
            types.where((type) => !vendorTypeIsServices(type)).toList();
        if (storeTypes.isEmpty) return const SizedBox.shrink();

        final selectedId = ref.watch(storeSelectedCategoryIdProvider);
        final allSelected = selectedId == 0;

        return SizedBox(
          height: 38,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _AllVendorTypeChip(
                  selected: allSelected,
                  onTap: () {
                    ref.read(storeSelectedCategoryIdProvider.notifier).state =
                        0;
                    ref
                        .read(storeSelectedSubCategoryIdProvider.notifier)
                        .state = 0;
                  },
                ),
                for (final type in storeTypes) ...[
                  const Gap(8),
                  _VendorTypeChip(
                    type: type,
                    selected: selectedId == type.id,
                    languageCode: languageCode,
                    onTap: () {
                      ref.read(storeSelectedCategoryIdProvider.notifier).state =
                          type.id;
                      ref
                          .read(storeSelectedSubCategoryIdProvider.notifier)
                          .state = 0;
                    },
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

class _AllVendorTypeChip extends StatelessWidget {
  const _AllVendorTypeChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE2C8F7) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.lightBorder),
        ),
        child: Center(
          child: Text(
            'All'.tr,
            style: AppFont.font14W600Black.copyWith(
              color: AppColor.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _VendorTypeChip extends StatelessWidget {
  const _VendorTypeChip({
    required this.type,
    required this.selected,
    required this.languageCode,
    required this.onTap,
  });

  final VendorTypeModel type;
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE2C8F7) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.lightBorder),
        ),
        child: Center(
          child: Text(
            type.name.localized(languageCode),
            style: AppFont.font14W600Black.copyWith(
              color: AppColor.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
