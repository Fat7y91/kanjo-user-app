import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../config/app_color.dart';

class AddressAnimatedBackground extends StatelessWidget {
  final Animation<double> animation;

  const AddressAnimatedBackground({
    super.key,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _AddressAnimatedBackgroundPainter(animation.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _AddressAnimatedBackgroundPainter extends CustomPainter {
  final double animationValue;

  _AddressAnimatedBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Animated circles
    for (int i = 0; i < 4; i++) {
      final radius = 80.0 + (i * 40.0);
      final x = size.width * (0.1 + (i * 0.2)) +
          math.sin(animationValue * 2 * math.pi + i) * 40;
      final y = size.height * (0.15 + (i * 0.15)) +
          math.cos(animationValue * 2 * math.pi + i) * 40;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = AppColor.primary.withOpacity(0.04 - (i * 0.008)),
      );
    }

    // Floating location pins
    for (int i = 0; i < 3; i++) {
      final x = size.width * (0.2 + (i * 0.25)) +
          math.cos(animationValue * 2 * math.pi + i * 0.5) * 20;
      final y = size.height * (0.2 + (i * 0.2)) +
          math.sin(animationValue * 2 * math.pi + i * 0.5) * 20;

      final pinPaint = Paint()
        ..color = AppColor.primary.withOpacity(0.06)
        ..style = PaintingStyle.fill;

      // Draw pin shape
      final pinPath = Path()
        ..moveTo(x, y)
        ..lineTo(x - 8, y + 12)
        ..lineTo(x, y + 10)
        ..lineTo(x + 8, y + 12)
        ..close();

      canvas.drawPath(pinPath, pinPaint);
      canvas.drawCircle(
        Offset(x, y),
        6,
        Paint()..color = AppColor.primary.withOpacity(0.08),
      );
    }
  }

  @override
  bool shouldRepaint(_AddressAnimatedBackgroundPainter oldDelegate) {
    return true;
  }
}
