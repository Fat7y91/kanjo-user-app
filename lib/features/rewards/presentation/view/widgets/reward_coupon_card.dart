import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/rewards/data/models/reward_model.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';

class RewardCouponCard extends StatelessWidget {
  const RewardCouponCard({
    super.key,
    required this.reward,
    required this.enabled,
    required this.onTap,
  });

  final RewardModel reward;
  final bool enabled;
  final VoidCallback onTap;

  static const double _height = 148;
  static const double _borderRadius = 8;
  static const double _stripWidth = 74;
  static const double _curveRadius = 12;
  static const double _curvePosition = _stripWidth - _curveRadius / 2;

  @override
  Widget build(BuildContext context) {
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final stripColor = enabled ? AppColor.guestOrange : AppColor.grey2;
    final name = reward.name.localized(languageCode);
    final description = reward.description.localized(languageCode);
    final minOrder = reward.minimumOrderAmount > 0
        ? 'Min. order @amount'.trParams({
            'amount': _money(reward.minimumOrderAmount),
          })
        : null;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: CouponCard(
        height: _height,
        borderRadius: _borderRadius,
        curveAxis: Axis.vertical,
        curveRadius: _curveRadius,
        curvePosition: _curvePosition,
        backgroundColor: AppColor.white,
        shadow: BoxShadow(
          color: AppColor.softShadowBase.withAlpha(20),
          blurRadius: 6,
          offset: const Offset(0, 4),
        ),
        firstChild: enabled
            ? const _AnimatedDiscountStrip(child: _DiscountStripLabel())
            : ColoredBox(
                color: AppColor.grey2,
                child: const _DiscountStripLabel(),
              ),
        secondChild: ColoredBox(
          color: AppColor.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '@count Points'.trParams({
                    'count': '${reward.requiredPoints}',
                  }),
                  style: AppFont.font12w500Grey2.copyWith(
                    color: AppColor.textBodySecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Gap(4),
                Text(
                  name,
                  style: AppFont.font16W500Black.copyWith(
                    color: AppColor.textDark,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(4),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: AppFont.font12w500Grey2.copyWith(
                      color: AppColor.textBodyTertiary,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (minOrder != null) ...[
                  if (description.isNotEmpty) const Gap(4),
                  Text(
                    minOrder,
                    style: AppFont.font12w500Grey2.copyWith(
                      color: AppColor.guestOrange,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const Gap(8),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: stripColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ImageOrSvg(
                            AppAssets.coin,
                            isLocal: true,
                            width: 20,
                            height: 20,
                            color: AppColor.onAccentSurface,
                          ),
                          const Gap(8),
                          Text(
                            'Complete purchase'.tr,
                            style: AppFont.font12W600White.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _money(double value) {
    final text =
        value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
    return '$text ${'EGP'.tr}';
  }
}

class _DiscountStripLabel extends StatelessWidget {
  const _DiscountStripLabel();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotatedBox(
        quarterTurns: 3,
        child: Text(
          'Discounts'.tr,
          style: AppFont.font20W600White.copyWith(
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _AnimatedDiscountStrip extends StatefulWidget {
  const _AnimatedDiscountStrip({required this.child});

  final Widget child;

  @override
  State<_AnimatedDiscountStrip> createState() => _AnimatedDiscountStripState();
}

class _AnimatedDiscountStripState extends State<_AnimatedDiscountStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + t, -1),
              end: Alignment(1 - t, 1),
              colors: [
                Color.lerp(AppColor.guestOrange, AppColor.primary, t)!,
                Color.lerp(AppColor.primary, AppColor.guestOrange, t)!,
              ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
