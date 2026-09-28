import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../flying_bird_config.dart';
import '../flying_bird_game.dart';
import 'world_components.dart';

class BirdComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<FlyingBirdGame> {
  BirdComponent()
      : super(
          size: Vector2.all(FlyingBirdConfig.birdSize),
          anchor: Anchor.center,
          priority: 20,
        );

  double _velocityY = 0;
  double _idleTime = 0;
  double _wingTime = 0;
  late double _startY;

  @override
  Future<void> onLoad() async {
    _placeAtStart();
    add(
      CircleHitbox.relative(
        0.72,
        parentSize: size,
        anchor: Anchor.center,
        position: size / 2,
      ),
    );
  }

  void _placeAtStart() {
    position = Vector2(game.size.x * 0.28, game.size.y * 0.42);
    _startY = position.y;
    _velocityY = 0;
    angle = 0;
    _idleTime = 0;
    _wingTime = 0;
  }

  void reset() {
    _placeAtStart();
  }

  void flap() {
    _velocityY = FlyingBirdConfig.flapVelocity;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _wingTime += dt;
    switch (game.phaseNotifier.value) {
      case FlyingBirdPhase.ready:
        _idleTime += dt;
        y = _startY + math.sin(_idleTime * 3.2) * 10;
        angle = 0;
      case FlyingBirdPhase.playing:
        _velocityY = math.min(
          _velocityY + FlyingBirdConfig.gravity * dt,
          FlyingBirdConfig.maxFallSpeed,
        );
        y += _velocityY * dt;
        angle = (_velocityY / FlyingBirdConfig.maxFallSpeed).clamp(-0.6, 0.9);
        if (y < size.y / 2) {
          y = size.y / 2;
          _velocityY = 0;
        }
      case FlyingBirdPhase.crashed:
        break;
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    final hit = other is Obstacle || other.parent is Obstacle;
    if (hit) {
      game.crash();
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 6),
        width: size.x * 0.9,
        height: size.y * 0.45,
      ),
      Paint()..color = const Color(0x33000000),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = FlyingBirdConfig.birdBody,
    );
    canvas.drawCircle(
      Offset(center.dx - 4, center.dy - 4),
      radius * 0.42,
      Paint()..color = const Color(0x33FFFFFF),
    );

    final wingFlap = math.sin(_wingTime * 10) * 7;
    final wingRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx - 4, center.dy + 4 + wingFlap),
        width: size.x * 0.62,
        height: size.y * 0.38,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(wingRect, Paint()..color = FlyingBirdConfig.birdWing);

    final beakPath = Path()
      ..moveTo(size.x - 4, center.dy - 3)
      ..lineTo(size.x + 10, center.dy + 2)
      ..lineTo(size.x - 4, center.dy + 7)
      ..close();
    canvas.drawPath(beakPath, Paint()..color = FlyingBirdConfig.birdBeak);

    canvas.drawCircle(
      Offset(center.dx + 8, center.dy - 8),
      6.5,
      Paint()..color = const Color(0xFFFFFFFF),
    );
    canvas.drawCircle(
      Offset(center.dx + 10, center.dy - 8),
      3.2,
      Paint()..color = FlyingBirdConfig.birdEye,
    );

    canvas.drawCircle(
      Offset(center.dx - 2, center.dy - radius + 4),
      4,
      Paint()..color = FlyingBirdConfig.birdWing,
    );
  }
}
