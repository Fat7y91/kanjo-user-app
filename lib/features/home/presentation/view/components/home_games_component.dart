import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class HomeGamesComponent extends StatefulWidget {
  const HomeGamesComponent({super.key});

  @override
  State<HomeGamesComponent> createState() => _HomeGamesComponentState();
}

class _HomeGamesComponentState extends State<HomeGamesComponent>
    with TickerProviderStateMixin {
  static const _loopDuration = Duration(milliseconds: 2600);
  static const _enterDuration = Duration(milliseconds: 500);
  static const _cardHeight = 92.0;
  static const _radius = 24.0;

  late final AnimationController _loop;
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(vsync: this, duration: _loopDuration)
      ..repeat();
    _enter = AnimationController(vsync: this, duration: _enterDuration)
      ..forward();
  }

  @override
  void dispose() {
    _loop.dispose();
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final direction =
        Directionality.of(context) == TextDirection.rtl ? -1.0 : 1.0;

    return FadeTransition(
      opacity: CurvedAnimation(parent: _enter, curve: Curves.easeOut),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: SizedBox(
          height: _cardHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_radius),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const ColoredBox(color: AppColor.primary),
                      IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _loop,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _PulsingPointsPainter(
                                progress: _loop.value,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: LiquidGlass.withOwnLayer(
                  settings: LiquidGlassSettings(
                    thickness: 16,
                    blur: 8,
                    glassColor: Colors.white.withAlpha(20),
                    lightIntensity: 1.15,
                    ambientStrength: 0.22,
                    saturation: 1.25,
                    refractiveIndex: 1.16,
                    chromaticAberration: 0.008,
                  ),
                  shape: const LiquidRoundedSuperellipse(
                    borderRadius: _radius,
                  ),
                  child: GlassGlow(
                    glowColor: Colors.white,
                    glowRadius: 0.9,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Get.toNamed('/games'),
                        borderRadius: BorderRadius.circular(_radius),
                        splashFactory: InkRipple.splashFactory,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              AnimatedBuilder(
                                animation: _loop,
                                builder: (context, child) {
                                  final t = _loop.value;
                                  final bob =
                                      math.sin(t * math.pi * 2) * 4;
                                  final tilt =
                                      math.sin(t * math.pi * 4) * 0.14;
                                  return Transform.translate(
                                    offset: Offset(0, bob),
                                    child: Transform.rotate(
                                      angle: tilt,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.videogame_asset_rounded,
                                    size: 24,
                                    color: AppColor.primary,
                                  ),
                                ),
                              ),
                              const Gap(12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Games & Entertainment'.tr,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFont.font16W600NearlyWhite
                                          .copyWith(
                                        color: AppColor.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Gap(4),
                                    Text(
                                      'Play and win'.tr,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFont.font12w500Grey2.copyWith(
                                        color: AppColor.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedBuilder(
                                animation: _loop,
                                builder: (context, child) {
                                  final nudge = math.sin(
                                        _loop.value * math.pi * 2,
                                      ) *
                                      4 *
                                      direction;
                                  return Transform.translate(
                                    offset: Offset(nudge, 0),
                                    child: child,
                                  );
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: AppColor.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
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

class _PulsingPointsPainter extends CustomPainter {
  const _PulsingPointsPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.isFinite || size.isEmpty) return;

    const sparks = <(double, double, double)>[
      (0.18, 0.28, 0.0),
      (0.34, 0.72, 0.18),
      (0.52, 0.22, 0.33),
      (0.68, 0.78, 0.48),
      (0.78, 0.32, 0.0),
      (0.88, 0.62, 0.33),
      (0.70, 0.52, 0.66),
      (0.12, 0.58, 0.78),
    ];

    for (final spark in sparks) {
      final phase = (progress + spark.$3) % 1;
      final pulse = math.sin(phase * math.pi * 2).abs();
      final opacity = (pulse * 180).round().clamp(0, 180);
      final radius = 1.6 + pulse * 2.2;
      canvas.drawCircle(
        Offset(size.width * spark.$1, size.height * spark.$2),
        radius,
        Paint()..color = Colors.white.withAlpha(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PulsingPointsPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

