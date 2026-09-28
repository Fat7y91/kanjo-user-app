import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/offers/data/models/offer_model.dart';
import 'package:heraj/features/offers/presentation/view/widgets/offer_banner.dart';
import 'package:heraj/features/products/presentation/managers/category_products_provider.dart';
import 'package:heraj/features/products/presentation/view/widgets/product_card.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/error_widget.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';

class CategoryProductsScreen extends ConsumerStatefulWidget {
  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    this.title,
    this.offer,
  });

  final int categoryId;
  final String? title;
  final OfferModel? offer;

  @override
  ConsumerState<CategoryProductsScreen> createState() =>
      _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends ConsumerState<CategoryProductsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 240) return;
    ref
        .read(fetchCategoryProductsProvider(widget.categoryId).notifier)
        .fetchNextPage();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync =
        ref.watch(fetchCategoryProductsProvider(widget.categoryId));
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final title = widget.title?.trim().isNotEmpty == true
        ? widget.title!.trim()
        : 'Products'.tr;

    return Scaffold(
      backgroundColor: AppColor.white,
      bottomNavigationBar: widget.offer == null
          ? null
          : OfferBanner(offer: widget.offer!),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Gap(8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(12),
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 18,
                        color: AppColor.textDark,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: AppFont.font18W700Black,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 24, height: 24),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(
                    fetchCategoryProductsProvider(widget.categoryId),
                  );
                  try {
                    await ref.read(
                      fetchCategoryProductsProvider(widget.categoryId).future,
                    );
                  } catch (_) {}
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    productsAsync.customWhen(
                      ref: ref,
                      refreshable:
                          fetchCategoryProductsProvider(widget.categoryId)
                              .future,
                      skipLoadingOnRefresh: true,
                      loading: () => SliverPadding(
                        padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                        sliver: SliverMasonryGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childCount: 4,
                          itemBuilder: (context, index) => const ShimmerEffect(
                            enable: true,
                            child: ProductCardPlaceholder(),
                          ),
                        ),
                      ),
                      error: (err, trace) => SliverFillRemaining(
                        hasScrollBody: false,
                        child: CustomErrorWidget(
                          object: err,
                          stackTrace: trace,
                          onRetry: () async {
                            ref.invalidate(
                              fetchCategoryProductsProvider(widget.categoryId),
                            );
                          },
                        ),
                      ),
                      data: (products) {
                        if (products.isEmpty) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                'No products found'.tr,
                                style: AppFont.font16W600Black,
                              ),
                            ),
                          );
                        }
                        final showFooter = !ref
                            .read(
                              fetchCategoryProductsProvider(widget.categoryId)
                                  .notifier,
                            )
                            .isLastPage();
                        return SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            12,
                            16,
                            12,
                            MediaQuery.paddingOf(context).bottom + 16,
                          ),
                          sliver: SliverMasonryGrid.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childCount:
                                products.length + (showFooter ? 1 : 0),
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
                                offer: widget.offer,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
