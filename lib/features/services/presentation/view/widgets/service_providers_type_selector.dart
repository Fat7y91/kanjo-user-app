import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/services/domain/entities/service_type_entity.dart';
import 'package:heraj/features/services/presentation/managers/service_providers_list_provider.dart';
import 'package:heraj/features/services/presentation/managers/services_provider.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';

class ServiceProvidersTypeSelector extends ConsumerWidget {
  const ServiceProvidersTypeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(fetchServiceTypesProvider);
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return typesAsync.customWhen(
      ref: ref,
      refreshable: fetchServiceTypesProvider.future,
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
      data: (types) {
        if (types.isEmpty) return const SizedBox.shrink();
        final selectedId = ref.watch(serviceProvidersSelectedTypeIdProvider);
        return SizedBox(
          height: 92,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _AllTypeCard(
                  selected: selectedId == 0,
                  onTap: () => ref
                      .read(serviceProvidersSelectedTypeIdProvider.notifier)
                      .state = 0,
                ),
                for (final type in types) ...[
                  const Gap(8),
                  _ServiceTypeCard(
                    type: type,
                    selected: selectedId == type.id,
                    languageCode: languageCode,
                    onTap: () => ref
                        .read(serviceProvidersSelectedTypeIdProvider.notifier)
                        .state = type.id,
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

class _AllTypeCard extends StatelessWidget {
  const _AllTypeCard({
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

class _ServiceTypeCard extends StatelessWidget {
  const _ServiceTypeCard({
    required this.type,
    required this.selected,
    required this.languageCode,
    required this.onTap,
  });

  final ServiceTypeEntity type;
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
                type.icon,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                pickImageOnNull: true,
                assetImageOnNull: AppAssets.homeCategoryServices,
              ),
            ),
            const Gap(6),
            Text(
              type.name.localized(languageCode),
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
