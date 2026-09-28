import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/rewards/presentation/managers/rewards_actions_mixin.dart';
import 'package:heraj/features/rewards/presentation/managers/rewards_provider.dart';
import 'package:heraj/features/rewards/presentation/view/widgets/reward_coupon_card.dart';
import 'package:heraj/features/rewards/presentation/view/widgets/rewards_summary_card.dart';
import 'package:heraj/helper/format_date.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen>
    with RewardsActionsMixin {
  @override
  Widget build(BuildContext context) {
    final centerAsync = ref.watch(fetchRewardsCenterProvider);

    return Scaffold(
      backgroundColor: AppColor.white,
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
                      'Rewards'.tr,
                      style: AppFont.font18W700Black,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 24, height: 24),
                ],
              ),
            ),
            Expanded(
              child: centerAsync.customWhen(
                ref: ref,
                refreshable: fetchRewardsCenterProvider.future,
                skipLoadingOnRefresh: true,
                loading: () => const PageLoadingWidget(),
                data: (center) {
                  final points = center.balance.pointsBalance;
                  final expireAt = center.balance.expireAt;
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(fetchRewardsCenterProvider);
                      try {
                        await ref.read(fetchRewardsCenterProvider.future);
                      } catch (_) {}
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          sliver: SliverToBoxAdapter(
                            child: RewardsSummaryCard(
                              couponsCount: center.validRewardsCount,
                              points: points,
                              onShowHistory: openTransactionsHistory,
                              expireAt: expireAt == null || expireAt.isEmpty
                                  ? null
                                  : FormatDate.call(expireAt),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              'Use your points'.tr,
                              style: AppFont.font18W700Black,
                            ),
                          ),
                        ),
                        if (center.rewards.isEmpty)
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
                            sliver: SliverToBoxAdapter(
                              child: Text(
                                'No rewards yet'.tr,
                                textAlign: TextAlign.center,
                                style: AppFont.font12w500Grey2,
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final reward = center.rewards[index];
                                  final usable = reward.isUsable(points);
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: index ==
                                              center.rewards.length - 1
                                          ? 0
                                          : 16,
                                    ),
                                    child: RewardCouponCard(
                                      reward: reward,
                                      enabled: usable,
                                      onTap: () => onRewardTap(
                                        reward: reward,
                                        availablePoints: points,
                                      ),
                                    ),
                                  );
                                },
                                childCount: center.rewards.length,
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
