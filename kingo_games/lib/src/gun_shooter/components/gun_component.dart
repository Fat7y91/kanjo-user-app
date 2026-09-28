import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../gun_shooter_config.dart';
import '../gun_shooter_game.dart';

class GunComponent extends PositionComponent
    with HasGameReference<GunShooterGame> {
  GunComponent()
      : super(
          size: Vector2.all(GunShooterConfig.gunSize),
          anchor: Anchor.center,
          priority: 20,
        );

  double _flashTimer = 0;

  Vector2 get muzzleWorldPosition {
    final muzzleLocal = Vector2(0, -size.y * 0.42);
    return absolutePositionOf(muzzleLocal);
  }

  @override
  Future<void> onLoad() async {
    reset();
  }

  void reset() {
    position = Vector2(
      game.size.x / 2,
      game.size.y - GunShooterConfig.groundHeight + 8,
    );
    angle = 0;
    _flashTimer = 0;
  }

  void aimAt(Vector2 worldPoint) {
    final delta = worldPoint - absolutePosition;
    // Keep the barrel roughly upward (not shooting into the ground).
    final raw = math.atan2(delta.x, -delta.y);
    angle = raw.clamp(-1.15, 1.15);
  }

  void flash() {
    _flashTimer = 0.08;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_flashTimer > 0) {
      _flashTimer = math.max(0, _flashTimer - dt);
    }
  }

  @override
  void render(Canvas canvas) {
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y * 0.62),
        width: size.x * 0.55,
        height: size.y * 0.42,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(body, Paint()..color = GunShooterConfig.gunBody);
    canvas.drawRRect(
      body,
      Paint()
        ..color = GunShooterConfig.gunDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final barrel = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y * 0.28),
        width: size.x * 0.22,
        height: size.y * 0.55,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(barrel, Paint()..color = GunShooterConfig.gunDark);

    if (_flashTimer > 0) {
      canvas.drawCircle(
        Offset(size.x / 2, size.y * 0.02),
        10,
        Paint()..color = GunShooterConfig.muzzleFlash.withAlpha(220),
      );
    }
  }
}
