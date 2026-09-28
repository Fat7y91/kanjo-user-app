import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';

class WalletBalanceCard extends StatefulWidget {
  const WalletBalanceCard({super.key, required this.balance});

  final double balance;

  @override
  State<WalletBalanceCard> createState() => _WalletBalanceCardState();
}

class _WalletBalanceCardState extends State<WalletBalanceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shine;

  @override
  void initState() {
    super.initState();
    _shine = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      builder: (context, enter, child) {
        return Opacity(
          opacity: enter,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - enter)),
            child: Transform.scale(
              scale: 0.96 + (0.04 * enter),
              child: child,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 168,
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColor.defaultPrimaryGradient2,
                ),
              ),
              PositionedDirectional(
                top: -36,
                end: -28,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(28),
                  ),
                ),
              ),
              PositionedDirectional(
                bottom: -48,
                start: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(18),
                  ),
                ),
              ),
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _shine,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _CardShinePainter(progress: _shine.value),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(230),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: ImageOrSvg(
                            AppAssets.coin,
                            isLocal: true,
                            width: 24,
                            height: 24,
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: Text(
                            'Available balance'.tr,
                            style: AppFont.font14W700White.copyWith(
                              color: Colors.white.withAlpha(220),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: widget.balance),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Text(
                          '${value.toStringAsFixed(2)} ${'EGP'.tr}',
                          style: AppFont.font48W500PrimaryBlue.copyWith(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                    ),
                    const Gap(4),
                    Text(
                      'Safe wallet'.tr,
                      style: AppFont.font12w500Grey2.copyWith(
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardShinePainter extends CustomPainter {
  const _CardShinePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.isFinite || size.isEmpty) return;
    final x = size.width * ((progress * 1.5) - 0.25);
    final rect = Rect.fromLTWH(x - 36, -20, 72, size.height + 40);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withAlpha(0),
            Colors.white.withAlpha(46),
            Colors.white.withAlpha(0),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _CardShinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
