import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/products/presentation/view/widgets/product_card.dart';
import 'package:heraj/features/search/presentation/managers/search_provider.dart';
import 'package:heraj/features/search/presentation/managers/search_screen_actions_mixin.dart';
import 'package:heraj/features/store/presentation/view/widgets/store_card.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SearchScreenActionsMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final ValueNotifier<String> _query;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _query = ValueNotifier<String>('');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _query.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _query.value = value.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  ),
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColor.lightBorder.withAlpha(80),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: AppColor.lightBorder),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            AppAssets.searchNormal,
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              AppColor.textGrey,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              onChanged: _onQueryChanged,
                              textInputAction: TextInputAction.search,
                              style: AppFont.font14W500Black,
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                hintText: 'Search products and stores'.tr,
                                hintStyle: AppFont.font14W500Black.copyWith(
                                  color: AppColor.textGrey,
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _controller,
                            builder: (context, value, _) {
                              if (value.text.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                onPressed: () {
                                  _debounce?.cancel();
                                  _controller.clear();
                                  _query.value = '';
                                  _focusNode.requestFocus();
                                },
                                icon: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: AppColor.textGrey,
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
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: _query,
                builder: (context, query, _) {
                  if (query.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Start typing to search'.tr,
                          textAlign: TextAlign.center,
                          style: AppFont.font14W500Black.copyWith(
                            color: AppColor.textGrey,
                          ),
                        ),
                      ),
                    );
                  }

                  final searchAsync = ref.watch(appSearchProvider(query));
                  return searchAsync.customWhen(
                    ref: ref,
                    refreshable: appSearchProvider(query).future,
                    loading: () => const PageLoadingWidget(),
                    data: (result) {
                      if (result.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'No results found'.tr,
                              style: AppFont.font16W600Black,
                            ),
                          ),
                        );
                      }

                      return CustomScrollView(
                        slivers: [
                          if (result.products.isNotEmpty) ...[
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 12),
                                child: Text(
                                  result.productGroupLabel.tr,
                                  style: AppFont.font16W600Black,
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              sliver: SliverMasonryGrid.count(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childCount: result.products.length,
                                itemBuilder: (context, index) {
                                  return ProductCard(
                                    product: result.products[index],
                                    languageCode: languageCode,
                                  );
                                },
                              ),
                            ),
                            const SliverToBoxAdapter(child: Gap(20)),
                          ],
                          if (result.vendors.isNotEmpty) ...[
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 12),
                                child: Text(
                                  result.vendorGroupLabel.tr,
                                  style: AppFont.font16W600Black,
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                12,
                                0,
                                12,
                                MediaQuery.paddingOf(context).bottom + 16,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    if (index.isOdd) return const Gap(10);
                                    final vendor = result.vendors[index ~/ 2];
                                    return StoreCard(
                                      vendor: vendor,
                                      languageCode: languageCode,
                                      onTap: () => openStoreDetails(vendor),
                                    );
                                  },
                                  childCount: result.vendors.length * 2 - 1,
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
