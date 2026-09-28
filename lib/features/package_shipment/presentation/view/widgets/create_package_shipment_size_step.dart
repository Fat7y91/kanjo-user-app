part of '../create_package_shipment_screen.dart';

class _SizeStep extends ConsumerWidget {
  const _SizeStep({
    super.key,
    required this.selectedId,
    required this.onSelect,
  });

  final int? selectedId;
  final ValueChanged<PackageSizeEntity> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizesAsync = ref.watch(fetchPackageSizesProvider);
    return sizesAsync.customWhen(
      ref: ref,
      refreshable: fetchPackageSizesProvider.future,
      loading: () => const PackageSizeStepShimmer(),
      data: (sizes) {
        if (sizes.isEmpty) {
          return Center(child: Text('No package sizes available'.tr));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sizes.length,
          separatorBuilder: (_, __) => const Gap(12),
          itemBuilder: (context, index) {
            final size = sizes[index];
            final selected = size.id == selectedId;
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => onSelect(size),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          selected ? AppColor.primary : AppColor.checkoutBorder,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColor.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.inventory_2_rounded,
                          color: AppColor.primary,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(size.name, style: AppFont.font16W600Black),
                            const Gap(4),
                            Text(
                              size.dimensionsLabel,
                              style: AppFont.font12w400Black,
                            ),
                            const Gap(2),
                            Text(
                              '${'Size multiplier'.tr}: ×${size.sizeMultiplier.toStringAsFixed(0)}',
                              style: AppFont.font12w400Black,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: selected
                            ? AppColor.primary
                            : AppColor.radioBorderGrey,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
