import 'package:flutter/widgets.dart';

final class GradientBoxBorder extends BoxBorder {
  const GradientBoxBorder({required this.gradient, this.width = 1.0});

  final Gradient gradient;

  final double width;

  @override
  BorderSide get bottom => BorderSide.none;

  @override
  BorderSide get top => BorderSide.none;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  bool get isUniform => true;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    switch (shape) {
      case BoxShape.circle:
        assert(
          borderRadius == null,
          'A borderRadius can only be given for rectangular boxes.',
        );
        _paintCircle(canvas, rect, textDirection: textDirection);
        break;
      case BoxShape.rectangle:
        if (borderRadius != null) {
          _paintRRect(canvas, rect, borderRadius, textDirection: textDirection);
          return;
        }
        _paintRect(canvas, rect, textDirection: textDirection);
        break;
    }
  }

  void _paintRect(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    canvas.drawRect(
      rect.deflate(width / 2),
      _getPaint(rect, textDirection: textDirection),
    );
  }

  void _paintRRect(
    Canvas canvas,
    Rect rect,
    BorderRadius borderRadius, {
    TextDirection? textDirection,
  }) {
    final rrect = borderRadius.toRRect(rect).deflate(width / 2);
    canvas.drawRRect(
      rrect,
      _getPaint(rect, textDirection: textDirection),
    );
  }

  void _paintCircle(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = _getPaint(rect, textDirection: textDirection);
    final radius = (rect.shortestSide - width) / 2.0;
    canvas.drawCircle(rect.center, radius, paint);
  }

  @override
  ShapeBorder scale(double t) {
    return this;
  }

  Paint _getPaint(Rect rect, {TextDirection? textDirection}) {
    final resolvedGradient = _resolveGradient(textDirection);
    return Paint()
      ..strokeWidth = width
      ..shader = resolvedGradient.createShader(rect)
      ..style = PaintingStyle.stroke;
  }

  Gradient _resolveGradient(TextDirection? textDirection) {
    final direction = textDirection ?? TextDirection.ltr;
    final g = gradient;

    if (g is LinearGradient) {
      return LinearGradient(
        begin: g.begin.resolve(direction),
        end: g.end.resolve(direction),
        colors: g.colors,
        stops: g.stops,
        tileMode: g.tileMode,
        transform: g.transform,
      );
    }

    if (g is RadialGradient) {
      return RadialGradient(
        center: g.center.resolve(direction),
        radius: g.radius,
        colors: g.colors,
        stops: g.stops,
        focal: g.focal?.resolve(direction),
        focalRadius: g.focalRadius,
        tileMode: g.tileMode,
        transform: g.transform,
      );
    }

    if (g is SweepGradient) {
      return SweepGradient(
        center: g.center.resolve(direction),
        startAngle: g.startAngle,
        endAngle: g.endAngle,
        colors: g.colors,
        stops: g.stops,
        tileMode: g.tileMode,
        transform: g.transform,
      );
    }

    return g;
  }
}
