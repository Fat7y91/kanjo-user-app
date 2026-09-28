import 'dart:ui';

import 'package:flame/components.dart';

import '../gun_shooter_config.dart';
import '../gun_shooter_game.dart';

class ShooterSkyBackground extends PositionComponent
    with HasGameReference<GunShooterGame> {
  ShooterSkyBackground() : super(priority: 0);

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
            GunShooterConfig.skyTop,
            GunShooterConfig.skyBottom,
          ],
        ),
    );

    final starPaint = Paint()..color = const Color(0x66FFFFFF);
    for (var i = 0; i < 28; i++) {
      final x = (i * 73) % size.x;
      final y = (i * 47) % (size.y * 0.65);
      canvas.drawCircle(Offset(x, y), i.isEven ? 1.6 : 1.1, starPaint);
    }
  }
}

class GroundStrip extends PositionComponent
    with HasGameReference<GunShooterGame> {
  GroundStrip() : super(priority: 5);

  @override
  Future<void> onLoad() async {
    _layout(game.size);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _layout(size);
  }

  void _layout(Vector2 gameSize) {
    size = Vector2(gameSize.x, GunShooterConfig.groundHeight);
    position = Vector2(0, gameSize.y - GunShooterConfig.groundHeight);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      Paint()..color = GunShooterConfig.groundColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, 4),
      Paint()..color = const Color(0xFF3A4B66),
    );
  }
}
