import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../flying_bird_config.dart';
import '../flying_bird_game.dart';

mixin Obstacle on PositionComponent {}

class SkyBackground extends PositionComponent
    with HasGameReference<FlyingBirdGame> {
  SkyBackground() : super(priority: 0);

  @override
  Future<void> onLoad() async {
    size = game.size.clone();
    position = Vector2.zero();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size.clone();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      Paint()
        ..shader = Gradient.linear(
          Offset.zero,
          Offset(0, size.y),
          const [
            FlyingBirdConfig.skyTop,
            FlyingBirdConfig.skyBottom,
          ],
        ),
    );
  }
}

class CloudsComponent extends Component with HasGameReference<FlyingBirdGame> {
  @override
  Future<void> onLoad() async {
    final random = math.Random(7);
    for (var i = 0; i < 5; i++) {
      add(
        _Cloud(
          startX: random.nextDouble() * game.size.x,
          y: 40 + random.nextDouble() * (game.size.y * 0.35),
          cloudScale: 0.7 + random.nextDouble() * 0.7,
        ),
      );
    }
  }
}

class _Cloud extends PositionComponent with HasGameReference<FlyingBirdGame> {
  _Cloud({
    required double startX,
    required double y,
    required this.cloudScale,
  }) : super(
          position: Vector2(startX, y),
          size: Vector2(90, 36),
          priority: 1,
        );

  final double cloudScale;

  @override
  void update(double dt) {
    super.update(dt);
    if (game.phaseNotifier.value == FlyingBirdPhase.crashed) {
      return;
    }
    x -= FlyingBirdConfig.cloudSpeed * dt * cloudScale;
    if (x + size.x * cloudScale < -20) {
      x = game.size.x + 20;
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xE6FFFFFF);
    canvas.drawOval(
      Rect.fromLTWH(0, 10, 54 * cloudScale, 22 * cloudScale),
      paint,
    );
    canvas.drawOval(
      Rect.fromLTWH(22 * cloudScale, 0, 48 * cloudScale, 28 * cloudScale),
      paint,
    );
    canvas.drawOval(
      Rect.fromLTWH(48 * cloudScale, 12, 40 * cloudScale, 20 * cloudScale),
      paint,
    );
  }
}

class GroundComponent extends PositionComponent
    with Obstacle, HasGameReference<FlyingBirdGame> {
  GroundComponent() : super(priority: 10);

  double _offset = 0;

  @override
  Future<void> onLoad() async {
    _layout(game.size);
    add(
      RectangleHitbox()..collisionType = CollisionType.passive,
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _layout(size);
  }

  void _layout(Vector2 gameSize) {
    size = Vector2(gameSize.x, FlyingBirdConfig.groundHeight);
    position = Vector2(0, gameSize.y - FlyingBirdConfig.groundHeight);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isPlaying) {
      return;
    }
    _offset = (_offset + FlyingBirdConfig.groundSpeed * dt) % 28;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      Paint()..color = FlyingBirdConfig.groundColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, 18),
      Paint()..color = FlyingBirdConfig.grassColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 18, size.x, 6),
      Paint()..color = FlyingBirdConfig.grassDark,
    );
    final stripePaint = Paint()..color = FlyingBirdConfig.groundDark;
    for (var x = -_offset; x < size.x; x += 28) {
      canvas.drawRect(Rect.fromLTWH(x, 28, 14, size.y - 28), stripePaint);
    }
  }
}
