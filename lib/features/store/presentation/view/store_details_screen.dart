import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/features/offers/data/models/offer_model.dart';
import 'package:heraj/features/offers/presentation/view/widgets/offer_banner.dart';
import 'package:heraj/features/cart/data/models/cart_item_model.dart';
import 'package:heraj/features/cart/presentation/managers/fetch_cart_provider.dart';
import 'package:heraj/features/categories/data/models/category_model.dart';
import 'package:heraj/features/categories/presentation/managers/fetch_categories_provider.dart';
import 'package:heraj/features/products/domain/use_case/fetch_products_params.dart';
import 'package:heraj/features/services/domain/entities/service_type_entity.dart';
import 'package:heraj/features/services/domain/use_case/fetch_provider_services_use_case.dart';
import 'package:heraj/features/services/presentation/managers/services_provider.dart';
import 'package:heraj/features/services/presentation/view/service_provider_details_screen.dart';
import 'package:heraj/features/services/presentation/view/widgets/provider_service_card.dart';
import 'package:heraj/features/store/presentation/manager/store_details_actions_mixin.dart';
import 'package:heraj/features/store/presentation/manager/store_details_provider.dart';
import 'package:heraj/features/store/presentation/view/widgets/offline_store_caution_sheet.dart';
import 'package:heraj/features/store/presentation/view/widgets/store_card.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/helper/extensions/adaptive_view.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';
import 'package:heraj/ui/shared_widgets/error_widget.dart';
import '../../../../config/app_font.dart';
import '../../../products/presentation/view/widgets/product_card.dart';
import '../../../vendor/data/models/vendor_model.dart';

class StoreDetailsScreen extends ConsumerStatefulWidget {
  const StoreDetailsScreen({
    super.key,
    required this.vendor,
    this.offer,
  });

  final VendorModel vendor;
  final OfferModel? offer;

  @override
  ConsumerState<StoreDetailsScreen> createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends ConsumerState<StoreDetailsScreen>
    with StoreDetailsActionsMixin {
  final ScrollController _scrollController = ScrollController();

  bool get _isPharma =>
      widget.vendor.type.id == 3 ||
      widget.vendor.type.key.toLowerCase() == 'pharmacy';

  bool get _isServices => isServicesVendorType(
        key: widget.vendor.type.key,
        en: widget.vendor.type.name.en,
        ar: widget.vendor.type.name.ar,
      );

  int get _vendorId => widget.vendor.id;

  int get _vendorTypeId => widget.vendor.type.id;

  FetchProductsParams get _productsParams {
    final selectedCategoryId =
        ref.watch(storeDetailsSelectedCategoryIdProvider);
    return FetchProductsParams(
      vendorId: _vendorId,
      categoryId: selectedCategoryId > 0 ? selectedCategoryId : null,
    );
  }

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
    if (_isServices || !_scrollController.hasClients) return;
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) {
      return;
    }
    final selectedCategoryId =
        ref.read(storeDetailsSelectedCategoryIdProvider);
    final params = FetchProductsParams(
      vendorId: _vendorId,
      categoryId: selectedCategoryId > 0 ? selectedCategoryId : null,
    );
    final notifier =
        ref.read(fetchStoreDetailsProductsProvider(params).notifier);
    if (notifier.isLastPage()) return;
    notifier.fetchNextPage();
  }

  String _formatMoney(double amount) {
    final text = amount % 1 == 0
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    return '$text ${'EGP'.tr}';
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final isServices = _isServices;
    final selectedCategoryId =
        ref.watch(storeDetailsSelectedCategoryIdProvider);
    final selectedServiceTypeId =
        ref.watch(storeDetailsSelectedServiceTypeIdProvider);
    final categoriesAsync = isServices
        ? null
        : ref.watch(fetchCategoriesByVendorTypeProvider(_vendorTypeId));
    final productsParams = _productsParams;
    final productsAsync = isServices
        ? null
        : ref.watch(fetchStoreDetailsProductsProvider(productsParams));
    final serviceTypesAsync =
        isServices ? ref.watch(fetchServiceTypesProvider) : null;
    final servicesParams = FetchProviderServicesParams(
      serviceProviderId: _vendorId,
      serviceTypeId:
          selectedServiceTypeId > 0 ? selectedServiceTypeId : null,
    );
    final servicesAsync = isServices
        ? ref.watch(fetchProviderServicesProvider(servicesParams))
        : null;
    final cartAsync = ref.watch(fetchCartProvider);
    final List<CartItemModel> vendorItems = isServices
        ? <CartItemModel>[]
        : cartAsync.maybeWhen(
            data: (cart) => cart.items
                .where((item) => item.vendorId == _vendorId)
                .toList(),
            orElse: () => <CartItemModel>[],
          );
    final itemsCount =
        vendorItems.fold<int>(0, (sum, item) => sum + item.quantity);
    final vendorTotal =
        vendorItems.fold<double>(0, (sum, item) => sum + item.lineTotal);

    final showVendorCartBar =
        !isServices && vendorItems.isNotEmpty && itemsCount > 0;
    final isOffline = isVendorOffline(widget.vendor);

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF6F6F6),
      bottomNavigationBar: widget.offer == null && !showVendorCartBar
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.offer != null)
                  OfferBanner(
                    offer: widget.offer!,
                    applySafeArea: !showVendorCartBar,
                  ),
                if (showVendorCartBar)
                  _BottomCartBar(
                    totalText: _formatMoney(vendorTotal),
                    itemsCountText: '$itemsCount',
                    actionText: 'View cart'.tr,
                    enabled: !isOffline,
                    onViewCart: () => Get.toNamed('/cart'),
                  ),
              ],
            ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _StoreHeaderDelegate(
                vendor: widget.vendor,
                isPharma: _isPharma,
                showCartButton: !isServices,
                actionsEnabled: !isOffline,
                languageCode: languageCode,
                topPadding: MediaQuery.paddingOf(context).top,
                isStartingConversation: ref.watch(
                  isLoadingProvider('startVendorConversation'),
                ),
                onConversationTap: () =>
                    startPharmacyConversation(widget.vendor),
                onStoreTap: isServices
                    ? () => Get.to(
                          () => ServiceProviderDetailsScreen(
                            serviceProviderId: _vendorId,
                          ),
                        )
                    : null,
              ),
            ),
            if (isServices) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: serviceTypesAsync!.customWhen(
                    ref: ref,
                    refreshable: fetchServiceTypesProvider.future,
                    loading: () => SizedBox(
                      height: 40,
                      child: Row(
                        children: List.generate(
                          4,
                          (i) => Padding(
                            padding: EdgeInsetsDirectional.only(
                              end: i < 3 ? 8 : 0,
                            ),
                            child: ShimmerEffect(
                              enable: true,
                              child: Container(
                                width: 80,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECECEC),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (types) => _ServiceTypesTabsRow(
                      types: types,
                      selectedTypeId: selectedServiceTypeId,
                      languageCode: languageCode,
                      onSelect: (id) => ref
                          .read(
                            storeDetailsSelectedServiceTypeIdProvider.notifier,
                          )
                          .state = id,
                    ),
                  ),
                ),
              ),
              servicesAsync!.customWhen(
                ref: ref,
                refreshable:
                    fetchProviderServicesProvider(servicesParams).future,
                loading: () => SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: ShimmerEffect(
                          enable: true,
                          child: SizedBox(height: 96, width: double.infinity),
                        ),
                      ),
                      childCount: 4,
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
                        fetchProviderServicesProvider(servicesParams),
                      );
                    },
                  ),
                ),
                data: (services) {
                  if (services.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No services found'.tr,
                          style: AppFont.font16W600Black,
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      12,
                      8,
                      12,
                      context.safeAreaBottom + 16,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final service = services[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ProviderServiceCard(
                              service: service,
                              languageCode: languageCode,
                              onTap: () => openBookService(
                                service: service,
                                vendor: widget.vendor,
                              ),
                            ),
                          );
                        },
                        childCount: services.length,
                      ),
                    ),
                  );
                },
              ),
            ] else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: categoriesAsync!.customWhen(
                    ref: ref,
                    refreshable:
                        fetchCategoriesByVendorTypeProvider(_vendorTypeId)
                            .future,
                    loading: () => SizedBox(
                      height: 40,
                      child: Row(
                        children: List.generate(
                          4,
                          (i) => Padding(
                            padding: EdgeInsetsDirectional.only(
                              end: i < 3 ? 8 : 0,
                            ),
                            child: ShimmerEffect(
                              enable: true,
                              child: Container(
                                width: 80,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECECEC),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (categories) => _CategoriesTabsRow(
                      categories: categories,
                      selectedCategoryId: selectedCategoryId,
                      languageCode: languageCode,
                      onSelect: (id) => ref
                          .read(storeDetailsSelectedCategoryIdProvider.notifier)
                          .state = id,
                    ),
                  ),
                ),
              ),
              productsAsync!.customWhen(
                ref: ref,
                refreshable:
                    fetchStoreDetailsProductsProvider(productsParams).future,
                loading: () => SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    12,
                    8,
                    12,
                    showVendorCartBar ? 120 : 16,
                  ),
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
                        fetchStoreDetailsProductsProvider(productsParams),
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
                        fetchStoreDetailsProductsProvider(productsParams)
                            .notifier,
                      )
                      .isLastPage();
                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      12,
                      8,
                      12,
                      context.safeAreaBottom + (showVendorCartBar ? 80 : 16),
                    ),
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
                          offer: widget.offer,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StoreHeaderDelegate extends SliverPersistentHeaderDelegate {
  _StoreHeaderDelegate({
    required this.vendor,
    required this.isPharma,
    required this.showCartButton,
    required this.actionsEnabled,
    required this.languageCode,
    required this.topPadding,
    required this.isStartingConversation,
    required this.onConversationTap,
    this.onStoreTap,
  });

  final VendorModel vendor;
  final bool isPharma;
  final bool showCartButton;
  final bool actionsEnabled;
  final String languageCode;
  final double topPadding;
  final bool isStartingConversation;
  final VoidCallback onConversationTap;
  final VoidCallback? onStoreTap;

  static const double _expandedLogo = 108;
  static const double _collapsedLogo = 36;
  static const double _collapsedBar = 56;

  @override
  double get maxExtent => topPadding + 148 + (_expandedLogo / 2) + 120;

  @override
  double get minExtent => topPadding + _collapsedBar;

  @override
  bool shouldRebuild(covariant _StoreHeaderDelegate oldDelegate) {
    return vendor != oldDelegate.vendor ||
        isPharma != oldDelegate.isPharma ||
        showCartButton != oldDelegate.showCartButton ||
        actionsEnabled != oldDelegate.actionsEnabled ||
        languageCode != oldDelegate.languageCode ||
        topPadding != oldDelegate.topPadding ||
        isStartingConversation != oldDelegate.isStartingConversation ||
        onConversationTap != oldDelegate.onConversationTap ||
        onStoreTap != oldDelegate.onStoreTap;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = (maxExtent - minExtent).clamp(1.0, double.infinity);
    final t = (shrinkOffset / range).clamp(0.0, 1.0);
    final logoSize =
        _expandedLogo + (_collapsedLogo - _expandedLogo) * t;
    final coverUrl = vendor.coverImageUrl?.isNotEmpty == true
        ? vendor.coverImageUrl
        : (vendor.imageUrl.isNotEmpty ? vendor.imageUrl : null);
    final logoUrl = vendor.logoUrl?.isNotEmpty == true ? vendor.logoUrl : null;
    final ratingText =
        vendor.rating <= 0 ? '-' : vendor.rating.toStringAsFixed(1);
    final availabilityText = vendor.availabilityStatus.replaceAll('_', ' ');
    final typeName = vendor.type.name.localized(languageCode);
    final expandedOpacity = (1 - t * 1.35).clamp(0.0, 1.0);
    final collapsedOpacity = ((t - 0.55) / 0.45).clamp(0.0, 1.0);

    return Material(
      color: Colors.white,
      elevation: t > 0.85 ? 2 : 0,
      shadowColor: Colors.black26,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cover (fades / shrinks as we collapse)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topPadding + 148 * (1 - t * 0.55),
            child: Opacity(
              opacity: (1 - t * 0.85).clamp(0.0, 1.0),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(22 * (1 - t)),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ImageOrSvg(
                      coverUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      pickImageOnNull: true,
                      assetImageOnNull: AppAssets.homeCategoryFood,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withAlpha(40),
                            Colors.black.withAlpha(10),
                            Colors.white.withAlpha(180),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Expanded meta under logo
          Positioned(
            left: 16,
            right: 16,
            top: topPadding + 148 + logoSize * 0.45,
            child: Opacity(
              opacity: expandedOpacity,
              child: IgnorePointer(
                ignoring: expandedOpacity < 0.2,
                child: Column(
                  children: [
                    InkWell(
                      onTap: onStoreTap,
                      borderRadius: BorderRadius.circular(8),
                      child: Text(
                        vendor.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppFont.font18W700Black,
                      ),
                    ),
                    const Gap(8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Pill(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: AppColor.gold,
                              ),
                              const Gap(6),
                              Text(
                                ratingText,
                                style: AppFont.font14W600Black.copyWith(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _Pill(
                          child: Text(
                            availabilityText.isNotEmpty
                                ? availabilityText
                                : 'online',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFont.font12W600Grey2.copyWith(
                              color: AppColor.textGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        _Pill(
                          child: Text(
                            typeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFont.font12w500Grey2.copyWith(
                              color: AppColor.textGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    VendorStatusChips(vendor: vendor),
                  ],
                ),
              ),
            ),
          ),

          // Collapsed title next to logo
          Positioned(
            left: 56,
            right: 56,
            top: topPadding,
            height: _collapsedBar,
            child: Opacity(
              opacity: collapsedOpacity,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  vendor.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppFont.font16W700Black,
                ),
              ),
            ),
          ),

          // Logo (moves from cover center toward collapsed bar)
          Positioned(
            left: 0,
            right: 0,
            top: topPadding +
                148 -
                logoSize / 2 -
                (148 - _collapsedBar / 2 - logoSize / 2) * t * 0.92,
            child: Align(
              alignment: AlignmentDirectional.lerp(
                    AlignmentDirectional.center,
                    AlignmentDirectional.centerStart,
                    collapsedOpacity,
                  ) ??
                  Alignment.center,
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  start: 52 * collapsedOpacity,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onStoreTap,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.white,
                          width: 4 - 2 * t,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x1A000000)
                                .withAlpha((26 * (1 - t)).round()),
                            blurRadius: 12 * (1 - t),
                            offset: Offset(0, 4 * (1 - t)),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: ImageOrSvg(
                          logoUrl,
                          width: logoSize,
                          height: logoSize,
                          fit: BoxFit.cover,
                          pickImageOnNull: true,
                          assetImageOnNull: AppAssets.logoOnly,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Top actions always visible
          PositionedDirectional(
            top: topPadding + 8,
            start: 12,
            child: _TopCircleIconButton(
              icon: Icons.arrow_back_ios_new,
              onTap: () => Get.back(closeOverlays: true),
            ),
          ),
          PositionedDirectional(
            top: topPadding + 8,
            end: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPharma) ...[
                  _TopCircleIconButton(
                    icon: CupertinoIcons.conversation_bubble,
                    isLoading: isStartingConversation,
                    onTap: actionsEnabled ? onConversationTap : null,
                  ),
                  const Gap(8),
                ],
                if (showCartButton)
                  _TopCircleIconButton(
                    icon: Icons.shopping_cart_outlined,
                    onTap:
                        actionsEnabled ? () => Get.toNamed('/cart') : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopCircleIconButton extends StatelessWidget {
  const _TopCircleIconButton({
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !isLoading;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 1,
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: enabled ? onTap : null,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: isLoading
                  ? const LoadingWidget(size: 16)
                  : Icon(icon, size: 20, color: AppColor.black),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.lightBorder),
      ),
      child: child,
    );
  }
}

class _CategoriesTabsRow extends StatelessWidget {
  const _CategoriesTabsRow({
    required this.categories,
    required this.selectedCategoryId,
    required this.languageCode,
    required this.onSelect,
  });

  final List<CategoryModel> categories;
  final int selectedCategoryId;
  final String languageCode;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          _TabChip(
            label: 'All'.tr,
            isSelected: selectedCategoryId == 0,
            onTap: () => onSelect(0),
            trailing: const Icon(Icons.grid_view_rounded, size: 18),
          ),
          const Gap(8),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const Gap(8),
              itemBuilder: (context, i) {
                final category = categories[i];
                return _TabChip(
                  label: category.name.localized(languageCode),
                  isSelected: selectedCategoryId == category.id,
                  onTap: () => onSelect(category.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTypesTabsRow extends StatelessWidget {
  const _ServiceTypesTabsRow({
    required this.types,
    required this.selectedTypeId,
    required this.languageCode,
    required this.onSelect,
  });

  final List<ServiceTypeEntity> types;
  final int selectedTypeId;
  final String languageCode;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _TabChip(
              label: 'All'.tr,
              isSelected: selectedTypeId == 0,
              onTap: () => onSelect(0),
              trailing: const Icon(Icons.grid_view_rounded, size: 18),
            ),
            for (final type in types) ...[
              const Gap(8),
              _TabChip(
                label: type.name.localized(languageCode),
                isSelected: selectedTypeId == type.id,
                onTap: () => onSelect(type.id),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? Colors.white : const Color(0xFFF0F0F0);
    final border = isSelected ? AppColor.primary : AppColor.lightBorder;
    final textColor = isSelected ? AppColor.primary : AppColor.textGrey;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppFont.font14W600Grey2.copyWith(color: textColor),
              ),
              if (trailing != null) ...[
                const Gap(8),
                IconTheme(
                  data: IconThemeData(color: textColor),
                  child: trailing!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomCartBar extends StatelessWidget {
  const _BottomCartBar({
    required this.totalText,
    required this.itemsCountText,
    required this.actionText,
    required this.onViewCart,
    this.enabled = true,
  });

  final String totalText;
  final String itemsCountText;
  final String actionText;
  final VoidCallback onViewCart;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [AppColor.lightShadow],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Row(
            children: [
              Text(
                totalText,
                style: AppFont.font20W700Black.copyWith(fontSize: 22),
              ),
              const Spacer(),
              Opacity(
                opacity: enabled ? 1 : 0.45,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColor.defaultPrimaryGradient2,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: enabled ? [AppColor.defaultPrimaryShadow] : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: enabled ? onViewCart : null,
                      borderRadius: BorderRadius.circular(999),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                itemsCountText,
                                style: AppFont.font14W700Black.copyWith(
                                  color: AppColor.primary,
                                ),
                              ),
                            ),
                            const Gap(10),
                            Text(
                              actionText,
                              style: AppFont.font16W600NearlyWhite.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
