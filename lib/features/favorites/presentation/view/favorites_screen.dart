import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/favorites/presentation/managers/favorites_actions_mixin.dart';
import 'package:heraj/features/favorites/presentation/managers/favorites_provider.dart';
import 'package:heraj/features/favorites/presentation/view/widgets/animated_favorite_card.dart';
import 'package:heraj/features/favorites/presentation/view/widgets/empty_favorites_state.dart';
import 'package:heraj/features/favorites/presentation/view/widgets/favorite_item_card.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/animated_background.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with TickerProviderStateMixin, FavoritesActionsMixin {
  late final AnimationController _backgroundAnimationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wishlistAsync = ref.watch(fetchWishlistProvider);
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(
            animation: _backgroundAnimationController,
          ),
          CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 96,
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColor.white.withAlpha(230),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: AppColor.black,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsetsDirectional.only(
                    start: 48,
                    bottom: 12,
                    end: 16,
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Favorites'.tr,
                        style: AppFont.font16W700Black,
                      ),
                      const Gap(6),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(seconds: 2),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.9 + (value * 0.1),
                            child: Transform.rotate(
                              angle: (1 - value) * 0.3,
                              child: child,
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: AppColor.danger,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  centerTitle: false,
                ),
              ),
              SliverToBoxAdapter(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(fetchWishlistProvider);
                    await ref.read(fetchWishlistProvider.future);
                  },
                  child: wishlistAsync.customWhen(
                    ref: ref,
                    refreshable: fetchWishlistProvider.future,
                    skipLoadingOnRefresh: true,
                    skipLoadingOnReload: true,
                    data: (items) {
                      if (items.isEmpty) {
                        return const EmptyFavoritesState();
                      }
                      final isRemoving = ref.watch(
                        isLoadingProvider('removeWishlist'),
                      );
                      return Column(
                        children: [
                          const Gap(10),
                          ...items.asMap().entries.map((entry) {
                            return AnimatedFavoriteCard(
                              key: ValueKey(entry.value.id),
                              index: entry.key,
                              child: FavoriteItemCard(
                                item: entry.value,
                                languageCode: languageCode,
                                isRemoving: isRemoving,
                                onRemove: () =>
                                    removeWishlistItem(entry.value.id),
                              ),
                            );
                          }),
                          Gap(MediaQuery.of(context).padding.bottom + 16),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
