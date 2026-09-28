import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/store/presentation/manager/store_provider.dart';
import 'package:heraj/features/store/presentation/manager/store_screen_actions_mixin.dart';
import 'package:heraj/features/store/presentation/view/widgets/store_card.dart';
import 'package:heraj/features/store/presentation/view/widgets/store_category_selector.dart';
import 'package:heraj/features/store/presentation/view/widgets/store_search_bar.dart';
import 'package:heraj/features/store/presentation/view/widgets/store_sort_filters_row.dart';
import 'package:heraj/features/store/presentation/view/widgets/store_sub_category_selector.dart';
import 'package:heraj/features/location/presentation/managers/location_provider.dart';
import 'package:heraj/features/offers/data/models/offer_model.dart';
import 'package:heraj/features/offers/presentation/view/widgets/offer_banner.dart';
import 'package:heraj/features/vendor/presentation/managers/fetch_vendors_provider.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/error_widget.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';
import 'package:heraj/ui/shared_widgets/sliver_delegate.dart';
import 'package:heraj/features/vendor/presentation/managers/fetch_vendor_types_provider.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({
    super.key,
    this.vendorTypeId,
    this.categoryId,
    this.offers = false,
    this.title,
    this.showVendorTypes = true,
    this.offer,
  });

  final int? vendorTypeId;
  final int? categoryId;
  final bool offers;
  final String? title;
  final bool showVendorTypes;
  final OfferModel? offer;

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen>
    with StoreScreenActionsMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vendorTypeId = widget.vendorTypeId;
      if (vendorTypeId != null && vendorTypeId > 0) {
        ref.read(storeSelectedCategoryIdProvider.notifier).state = vendorTypeId;
      }
      final categoryId = widget.categoryId;
      if (categoryId != null && categoryId > 0) {
        ref.read(storeSelectedSubCategoryIdProvider.notifier).state =
            categoryId;
      }
      if (widget.offers) {
        ref.read(storeOffersFilterProvider.notifier).state = true;
      }
    });
  }

  int _resolvedVendorTypeId(int selectedId) {
    if (widget.showVendorTypes) return selectedId;
    if (selectedId > 0) return selectedId;
    return widget.vendorTypeId ?? 0;
  }

  VendorsQuery _vendorsQuery() {
    final geo = ref.read(vendorsGeoParamsProvider);
    return VendorsQuery(
      vendorTypeId: _resolvedVendorTypeId(
        ref.read(storeSelectedCategoryIdProvider),
      ),
      categoryId: ref.read(storeSelectedSubCategoryIdProvider),
      search: ref.read(storeSearchQueryProvider),
      isFeatured: ref.read(storeIsFeaturedFilterProvider),
      offers: ref.read(storeOffersFilterProvider),
    ).withGeo(geo);
  }

  @override
  void dispose() {
    cancelSearchDebounce();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) {
      return;
    }
    final notifier = ref.read(fetchVendorsProvider(_vendorsQuery()).notifier);
    if (notifier.isLastPage()) return;
    notifier.fetchNextPage();
  }

  @override
  Widget build(BuildContext context) {
    final vendorTypeId = ref.watch(storeSelectedCategoryIdProvider);
    final categoryId = ref.watch(storeSelectedSubCategoryIdProvider);
    final search = ref.watch(storeSearchQueryProvider);
    final isFeatured = ref.watch(storeIsFeaturedFilterProvider);
    final offers = ref.watch(storeOffersFilterProvider);
    final geo = ref.watch(vendorsGeoParamsProvider);
    final query = VendorsQuery(
      vendorTypeId: _resolvedVendorTypeId(vendorTypeId),
      categoryId: categoryId,
      search: search,
      isFeatured: isFeatured,
      offers: offers,
    ).withGeo(geo);
    final vendorsAsync = ref.watch(fetchVendorsProvider(query));
    final vendors = ref.watch(filteredVendorsProvider(query));
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppColor.pageBackgroundGrey,
      extendBody: true,
      bottomNavigationBar: widget.offer == null
          ? null
          : OfferBanner(offer: widget.offer!),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(fetchVendorTypesProvider);
            ref.invalidate(fetchVendorsProvider(query));
            await Future.wait([
              ref.read(fetchVendorTypesProvider.future),
              ref.read(fetchVendorsProvider(query).future),
            ].map((future) => future.then<void>((_) {}, onError: (_) {})));
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (!widget.showVendorTypes)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: onBack,
                          borderRadius: BorderRadius.circular(12),
                          child: const SizedBox(
                            width: 24,
                            height: 24,
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: 18,
                              color: AppColor.textDark,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.title ?? 'Store'.tr,
                            style: AppFont.font18W700Black.copyWith(
                              color: AppColor.textDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 24, height: 24),
                      ],
                    ),
                  ),
                ),
              SliverPersistentHeader(
                pinned: true,
                floating: true,
                delegate: SliverDelegate(
                  height: 72,
                  child: StoreSearchBar(onChanged: onSearchChanged),
                ),
              ),
              if (widget.showVendorTypes) ...[
                const SliverToBoxAdapter(child: StoreVendorTypeSelector()),
                const SliverGap(8),
              ],
              const SliverToBoxAdapter(child: StoreCategorySelector()),
              const SliverGap(8),
              SliverToBoxAdapter(
                child: StoreSortFiltersRow(
                  sortType: ref.watch(storeSortTypeProvider),
                  offersSelected: ref.watch(storeOffersFilterProvider),
                  featuredSelected: ref.watch(storeIsFeaturedFilterProvider),
                  onSelectSort: onSortSelected,
                  onToggleOffers: onOffersFilterToggled,
                  onToggleFeatured: onFeaturedFilterToggled,
                ),
              ),
              vendorsAsync.customWhen(
                ref: ref,
                refreshable: fetchVendorsProvider(query).future,
                loading: () => SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index.isOdd) return const Gap(10);
                        return const ShimmerEffect(
                          enable: true,
                          child: StoreCardPlaceholder(),
                        );
                      },
                      childCount: 5,
                    ),
                  ),
                ),
                error: (err, trace) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: CustomErrorWidget(
                    object: err,
                    stackTrace: trace,
                    onRetry: () async {
                      ref.invalidate(fetchVendorsProvider(query));
                    },
                  ),
                ),
                data: (_) {
                  if (vendors.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No stores found'.tr,
                          style: AppFont.font16W500Black,
                        ),
                      ),
                    );
                  }
                  final showFooter = !ref
                      .read(fetchVendorsProvider(query).notifier)
                      .isLastPage();
                  final rowCount =
                      vendors.length * 2 - 1 + (showFooter ? 2 : 0);
                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      12,
                      0,
                      12,
                      MediaQuery.paddingOf(context).bottom,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (showFooter && index == rowCount - 1) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: LoadingWidget(size: 24),
                            );
                          }
                          if (index.isOdd) return const Gap(10);
                          final vendor = vendors[index ~/ 2];
                          return StoreCard(
                            vendor: vendor,
                            languageCode: languageCode,
                            onTap: () => openStoreDetails(vendor),
                          );
                        },
                        childCount: rowCount,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
