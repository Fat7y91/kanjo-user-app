import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/ui/shared_widgets/grediant_box.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';

class RewardsSummaryCard extends StatelessWidget {
  const RewardsSummaryCard({
    super.key,
    required this.couponsCount,
    required this.points,
    required this.onShowHistory,
    this.expireAt,
  });

  final int couponsCount;
  final int points;
  final VoidCallback onShowHistory;
  final String? expireAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColor.defaultPrimaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Use your rewards and coupons'.tr,
            style: AppFont.font18W700Black.copyWith(
              color: AppColor.onAccentSurface,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Gap(12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _GradientBorderBox(
                  child: Row(
                    children: [
                      ImageOrSvg(
                        AppAssets.ticket,
                        isLocal: true,
                        width: 32,
                        height: 32,
                      ),
                      const Gap(10),
                      Expanded(
                        child: Text(
                          '@count Coupons'.trParams({
                            'count': '$couponsCount',
                          }),
                          style: AppFont.font16W500Black.copyWith(
                            color: AppColor.onAccentSurface,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(8),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onShowHistory,
                    borderRadius: BorderRadius.circular(12),
                    splashFactory: InkRipple.splashFactory,
                    child: _GradientBorderBox(
                      child: Row(
                        children: [
                          ImageOrSvg(
                            AppAssets.coin,
                            isLocal: true,
                            width: 32,
                            height: 32,
                          ),
                          const Gap(10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '@count Points'.trParams({
                                    'count': '$points',
                                  }),
                                  style: AppFont.font16W500Black.copyWith(
                                    color: AppColor.onAccentSurface,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const Gap(2),
                                Text(
                                  'Show history'.tr,
                                  style: AppFont.font12w500Grey2.copyWith(
                                    color: AppColor.lightBorder,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (expireAt != null && expireAt!.trim().isNotEmpty) ...[
            const Gap(12),
            _GradientBorderBox(
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: AppColor.onAccentSurface,
                  ),
                  const Gap(10),
                  Expanded(
                    child: Text(
                      'Points expire on @date'.trParams({'date': expireAt!}),
                      style: AppFont.font12w500Grey2.copyWith(
                        color: AppColor.onAccentSurface,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GradientBorderBox extends StatelessWidget {
  const _GradientBorderBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    const borderRadius = 12.0;
    const borderWidth = 1.2;
    return Container(
      decoration: BoxDecoration(
        gradient: AppColor.defaultPrimaryGradient,
        border: GradientBoxBorder(
          gradient: AppColor.goldGradient,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: const EdgeInsets.all(borderWidth),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        ),
        child: child,
      ),
    );
  }
}
