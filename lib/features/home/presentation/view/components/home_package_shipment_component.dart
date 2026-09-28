import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/package_shipment/presentation/view/create_package_shipment_screen.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class HomePackageShipmentComponent extends StatefulWidget {
  const HomePackageShipmentComponent({super.key});

  @override
  State<HomePackageShipmentComponent> createState() =>
      _HomePackageShipmentComponentState();
}

class _HomePackageShipmentComponentState
    extends State<HomePackageShipmentComponent> with TickerProviderStateMixin {
  static const _loopDuration = Duration(milliseconds: 2800);
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                      const ColoredBox(color: AppColor.primary2),
                      IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _loop,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _RoutePulsePainter(
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
                        onTap: () =>
                            Get.to(() => const CreatePackageShipmentScreen()),
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
                                  final bob = math.sin(t * math.pi * 2) * 3.5;
                                  return Transform.translate(
                                    offset: Offset(0, bob),
                                    child: child,
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
                                    Icons.local_shipping_rounded,
                                    size: 24,
                                    color: AppColor.primary2,
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
                                      'Send a package'.tr,
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
                                      'Door to door delivery'.tr,
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
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: AppColor.primary2,
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

class _RoutePulsePainter extends CustomPainter {
  const _RoutePulsePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.isFinite || size.isEmpty) return;

    final path = Path()
      ..moveTo(size.width * 0.12, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.18,
        size.width * 0.55,
        size.height * 0.55,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.88,
        size.width * 0.9,
        size.height * 0.28,
      );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withAlpha(50);
    canvas.drawPath(path, paint);

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final distance = metric.length * progress;
    final tangent = metric.getTangentForOffset(distance);
    if (tangent == null) return;

    canvas.drawCircle(
      tangent.position,
      5,
      Paint()..color = Colors.white.withAlpha(220),
    );
    canvas.drawCircle(
      tangent.position,
      10 + (math.sin(progress * math.pi * 2).abs() * 4),
      Paint()..color = Colors.white.withAlpha(40),
    );
  }

  @override
  bool shouldRepaint(covariant _RoutePulsePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
