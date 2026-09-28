import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

class BurstParticle extends PositionComponent {
  BurstParticle({
    required Vector2 position,
    required this.color,
    this.life = 0.35,
    this.radius = 4,
  }) : super(position: position, anchor: Anchor.center, priority: 40);

  final Color color;
  final double life;
  final double radius;
  double _t = 0;
  late final Vector2 _vel;

  @override
  Future<void> onLoad() async {
    final random = math.Random();
    final angle = random.nextDouble() * math.pi * 2;
    final speed = 40 + random.nextDouble() * 90;
    _vel = Vector2(math.cos(angle), math.sin(angle)) * speed;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    position += _vel * dt;
    if (_t >= life) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final k = (1 - _t / life).clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset.zero,
      radius * k,
      Paint()..color = color.withAlpha((200 * k).round()),
    );
  }
}

class ExplosionPulse extends PositionComponent {
  ExplosionPulse({
    required Vector2 position,
    required this.maxRadius,
    this.color = const Color(0xFFFF9800),
    this.life = 0.28,
  }) : super(position: position, anchor: Anchor.center, priority: 35);

  final double maxRadius;
  final Color color;
  final double life;
  double _t = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    if (_t >= life) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final k = (_t / life).clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset.zero,
      maxRadius * k,
      Paint()
        ..color = color.withAlpha((180 * (1 - k)).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6 * (1 - k),
    );
  }
}

class RingPulse extends PositionComponent {
  RingPulse({
    required Vector2 position,
    required this.maxRadius,
    this.color = const Color(0xFF7C4DFF),
    this.life = 0.22,
  }) : super(position: position, anchor: Anchor.center, priority: 30);

  final double maxRadius;
  final Color color;
  final double life;
  double _t = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    if (_t >= life) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final k = (_t / life).clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset.zero,
      maxRadius * (0.4 + 0.6 * k),
      Paint()
        ..color = color.withAlpha((160 * (1 - k)).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8 * (1 - k),
    );
  }
}

void spawnBurst(
  Component parent,
  Vector2 position,
  Color color, {
  int count = 6,
}) {
  for (var i = 0; i < count; i++) {
    parent.add(BurstParticle(position: position.clone(), color: color));
  }
}
