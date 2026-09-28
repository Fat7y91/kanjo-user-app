import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/services/presentation/managers/services_provider.dart';
import 'package:heraj/features/services/presentation/view/service_providers_screen.dart';
import 'package:heraj/features/store/presentation/view/store_screen.dart';
import 'package:heraj/features/vendor/data/models/vendor_type_model.dart';
import 'package:heraj/features/vendor/presentation/managers/fetch_vendor_types_provider.dart';
import 'package:heraj/helper/extensions/adaptive_view.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';

class HomeCategoriesComponent extends ConsumerWidget {
  const HomeCategoriesComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fetchVendorTypesProvider);
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return state.customWhen(
      ref: ref,
      refreshable: fetchVendorTypesProvider.future,
      loading: () => const _VendorTypesShimmer(),
      data: (types) {
        if (types.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          child: MasonryGridView.count(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: types.length,
            crossAxisCount: context.responsiveGridColumns(
              mobile: 3,
              tablet: 4,
              desktop: 5,
            ),
            itemBuilder: (context, index) {
              return _VendorTypeChip(
                type: types[index],
                languageCode: languageCode,
              );
            },
          ),
        );
      },
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _VendorTypeChip extends StatelessWidget {
  const _VendorTypeChip({
    required this.type,
    required this.languageCode,
  });

  final VendorTypeModel type;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final title = type.name.localized(languageCode);
    return InkWell(
      onTap: () {
        if (vendorTypeIsServices(type)) {
          Get.to(() => ServiceProvidersScreen(title: title));
          return;
        }
        Get.to(
          () => StoreScreen(
            vendorTypeId: type.id,
            title: title,
            showVendorTypes: false,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: SizedBox(
                height: context
                    .responsiveGridColumns(
                      mobile: 120,
                      tablet: 150,
                      desktop: 150,
                    )
                    .toDouble(),
                child: ImageOrSvg(
                  type.imageUrl,
                  height: context
                      .responsiveGridColumns(
                        mobile: 120,
                        tablet: 150,
                        desktop: 150,
                      )
                      .toDouble(),
                  fit: BoxFit.fitHeight,
                  pickImageOnNull: true,
                  assetImageOnNull: AppAssets.homeCategoryServices,
                ),
              ),
            ),
            Text(
              type.name.localized(languageCode),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFont.font13W400Black.copyWith(
                color: AppColor.textDark,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorTypesShimmer extends StatelessWidget {
  const _VendorTypesShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      child: MasonryGridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: context.responsiveGridColumns(
          mobile: 6,
          tablet: 8,
          desktop: 10,
        ),
        padding: EdgeInsets.zero,
        crossAxisCount: context.responsiveGridColumns(
          mobile: 3,
          tablet: 4,
          desktop: 5,
        ),
        itemBuilder: (_, __) => ShimmerEffect(
          enable: true,
          child: Container(
            height: context
                .responsiveGridColumns(
                  mobile: 100,
                  tablet: 130,
                  desktop: 150,
                )
                .toDouble(),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
