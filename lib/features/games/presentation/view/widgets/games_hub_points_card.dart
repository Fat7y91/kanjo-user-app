import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/games/data/models/rewards_balance_model.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';

class GamesHubPointsCard extends StatelessWidget {
  const GamesHubPointsCard({
    super.key,
    required this.balance,
    this.onTap,
  });

  final RewardsBalanceModel balance;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashFactory: InkRipple.splashFactory,
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColor.defaultPrimaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColor.primary.withAlpha(48),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              ImageOrSvg(
                AppAssets.coin,
                isLocal: true,
                width: 28,
                height: 28,
              ),
              const Gap(8),
              Text(
                'Your points'.tr,
                style: AppFont.font12w500Grey2.copyWith(color: Colors.white),
              ),
              const Gap(4),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0,
                  end: balance.pointsBalance.toDouble(),
                ),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return Text(
                    value.round().toString(),
                    style: AppFont.font24w600Black.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 32,
                    ),
                  );
                },
              ),
              const Gap(4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Points history'.tr,
                    style: AppFont.font12w500Grey2.copyWith(
                      color: Colors.white.withAlpha(220),
                      fontSize: 11,
                    ),
                  ),
                  const Gap(4),
                  Icon(
                    Icons.history_rounded,
                    size: 14,
                    color: Colors.white.withAlpha(220),
                  ),
                ],
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      label: 'Total earned'.tr,
                      value: balance.totalEarned,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: Colors.white.withAlpha(51),
                  ),
                  Expanded(
                    child: _StatTile(
                      label: 'Total redeemed'.tr,
                      value: balance.totalRedeemed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: value.toDouble()),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, animated, _) {
            return Text(
              animated.round().toString(),
              style: AppFont.font16W700Black.copyWith(color: Colors.white),
            );
          },
        ),
        const Gap(2),
        Text(
          label,
          style: AppFont.font12w500Grey2.copyWith(
            color: Colors.white.withAlpha(220),
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
