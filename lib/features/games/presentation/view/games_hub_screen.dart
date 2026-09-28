import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/games/presentation/managers/games_hub_actions_mixin.dart';
import 'package:heraj/features/games/presentation/managers/games_provider.dart';
import 'package:heraj/features/games/presentation/view/arena_survival_game_screen.dart';
import 'package:heraj/features/games/presentation/view/flying_bird_game_screen.dart';
import 'package:heraj/features/games/presentation/view/gun_shooter_game_screen.dart';
import 'package:heraj/features/games/presentation/view/widgets/games_hub_game_card.dart';
import 'package:heraj/features/games/presentation/view/widgets/games_hub_limits_row.dart';
import 'package:heraj/features/games/presentation/view/widgets/games_hub_points_card.dart';
import 'package:heraj/features/games/presentation/view/widgets/games_hub_shimmer.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/fade_in_animation.dart';
import 'package:kingo_games/kingo_games.dart';

class GamesHubScreen extends ConsumerStatefulWidget {
  const GamesHubScreen({super.key});

  @override
  ConsumerState<GamesHubScreen> createState() => _GamesHubScreenState();
}

class _GamesHubScreenState extends ConsumerState<GamesHubScreen>
    with GamesHubActionsMixin {
  @override
  Widget build(BuildContext context) {
    final centerAsync = ref.watch(fetchGameCenterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(12),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: AppColor.textDark,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Games & Entertainment'.tr,
                      textAlign: TextAlign.center,
                      style: AppFont.font18W700Black,
                    ),
                  ),
                  const SizedBox(width: 40, height: 40),
                ],
              ),
            ),
            Expanded(
              child: centerAsync.customWhen(
                ref: ref,
                refreshable: fetchGameCenterProvider.future,
                skipLoadingOnRefresh: true,
                loading: () => const GamesHubShimmer(),
                data: (center) {
                  final enabled = center.config.enabled;
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(fetchGameCenterProvider);
                      try {
                        await ref.read(fetchGameCenterProvider.future);
                      } catch (_) {}
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                FadeInAnimation(
                                  delay: 0.8,
                                  fadeOffset: 28,
                                  direction: FadeInDirection.topToBottom,
                                  child: GamesHubPointsCard(
                                    balance: center.balance,
                                    onTap: openPointsTransactions,
                                  ),
                                ),
                                const Gap(12),
                                FadeInAnimation(
                                  delay: 1.0,
                                  fadeOffset: 24,
                                  direction: FadeInDirection.bottomToTop,
                                  child: GamesHubLimitsRow(
                                    dailyGames: center.balance.dailyGames,
                                  ),
                                ),
                                if (!enabled) ...[
                                  const Gap(12),
                                  Text(
                                    'Games are currently unavailable'.tr,
                                    textAlign: TextAlign.center,
                                    style: AppFont.font12w500Grey2,
                                  ),
                                ],
                                const Gap(16),
                                FadeInAnimation(
                                  delay: 1.15,
                                  fadeOffset: 24,
                                  direction: FadeInDirection.bottomToTop,
                                  child: GamesHubGameCard(
                                    title: 'Flying Bird'.tr,
                                    subtitle: 'Tap to fly'.tr,
                                    icon: Icons.flutter_dash_rounded,
                                    enabled: enabled,
                                    onTap: () => openGame(
                                      enabled: enabled,
                                      screen: const FlyingBirdGameScreen(),
                                    ),
                                  ),
                                ),
                                const Gap(12),
                                FadeInAnimation(
                                  delay: 1.3,
                                  fadeOffset: 24,
                                  direction: FadeInDirection.bottomToTop,
                                  child: GamesHubGameCard(
                                    title: 'Gun Shooter'.tr,
                                    subtitle: 'Tap to shoot'.tr,
                                    asset: ArenaAssets.bullet,
                                    enabled: enabled,
                                    onTap: () => openGame(
                                      enabled: enabled,
                                      screen: const GunShooterGameScreen(),
                                    ),
                                  ),
                                ),
                                const Gap(12),
                                FadeInAnimation(
                                  delay: 1.45,
                                  fadeOffset: 24,
                                  direction: FadeInDirection.bottomToTop,
                                  child: GamesHubGameCard(
                                    title: 'Arena Survival'.tr,
                                    subtitle:
                                        'Survive 5 minutes and defeat the guardian'
                                            .tr,
                                    asset: ArenaAssets.zombieBasic,
                                    enabled: enabled,
                                    onTap: () => openGame(
                                      enabled: enabled,
                                      screen: const ArenaSurvivalGameScreen(),
                                    ),
                                  ),
                                ),
                                Gap(MediaQuery.of(context).padding.bottom + 24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
