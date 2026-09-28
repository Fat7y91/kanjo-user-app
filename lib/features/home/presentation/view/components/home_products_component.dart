import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/home/presentation/managers/home_products_provider.dart';
import 'package:heraj/features/products/presentation/view/widgets/product_card.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';

class HomeProductsComponent extends ConsumerWidget {
  const HomeProductsComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProductsProvider);
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return state.customWhen(
      ref: ref,
      refreshable: homeProductsProvider.future,
      skipLoadingOnRefresh: true,
      loading: () => const SliverToBoxAdapter(child: _HomeProductsShimmer()),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
      data: (products) {
        if (products.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        final showFooter =
            !ref.read(homeProductsProvider.notifier).isLastPage();
        return SliverMainAxisGroup(
          slivers: [
            const SliverToBoxAdapter(child: _HomeProductsHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childCount: products.length + (showFooter ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= products.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: LoadingWidget(size: 24),
                    );
                  }
                  return ProductCard(
                    product: products[index],
                    languageCode: languageCode,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HomeProductsHeader extends StatelessWidget {
  const _HomeProductsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(
        'All products'.tr,
        style: AppFont.font16W600Black.copyWith(
          color: AppColor.textDark,
        ),
      ),
    );
  }
}

class _HomeProductsShimmer extends StatelessWidget {
  const _HomeProductsShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ShimmerEffect(
              enable: true,
              child: Container(
                width: 140,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const Gap(12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: ShimmerEffect(
                  enable: true,
                  child: ProductCardPlaceholder(),
                ),
              ),
              const Gap(12),
              const Expanded(
                child: ShimmerEffect(
                  enable: true,
                  child: ProductCardPlaceholder(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
