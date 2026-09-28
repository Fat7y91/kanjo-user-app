import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../gun_shooter_config.dart';
import '../gun_shooter_game.dart';
import 'enemy_component.dart';

class BulletComponent extends CircleComponent
    with CollisionCallbacks, HasGameReference<GunShooterGame> {
  BulletComponent({
    required Vector2 position,
    required this.direction,
  }) : super(
          radius: GunShooterConfig.bulletRadius,
          position: position,
          anchor: Anchor.center,
          paint: Paint()..color = GunShooterConfig.bulletColor,
          priority: 15,
        );

  final Vector2 direction;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isPlaying) {
      return;
    }
    position += direction * GunShooterConfig.bulletSpeed * dt;
    if (x < -20 ||
        y < -20 ||
        x > game.size.x + 20 ||
        y > game.size.y + 20) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is EnemyComponent) {
      other.hit();
      removeFromParent();
    }
  }
}
