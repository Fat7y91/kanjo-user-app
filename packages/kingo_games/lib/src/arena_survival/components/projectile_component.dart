import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../models/weapon_config.dart';
import 'boss_component.dart';
import 'enemy_component.dart';

class ProjectileComponent extends PositionComponent with CollisionCallbacks {
  ProjectileComponent({
    required Vector2 position,
    required this.direction,
    required this.weapon,
    required this.damage,
    required this.onHit,
    this.sprite,
  }) : super(
          position: position,
          size: Vector2.all(
            weapon.id == WeaponId.fireball ? 28 : 22,
          ),
          anchor: Anchor.center,
          angle: math.atan2(direction.y, direction.x) + math.pi / 2,
          priority: 16,
        );

  final Vector2 direction;
  final WeaponConfig weapon;
  final double damage;
  final Sprite? sprite;
  final void Function(ProjectileComponent projectile, PositionComponent target)
      onHit;
  bool spent = false;

  @override
  Future<void> onLoad() async {
    add(
      CircleHitbox.relative(
        0.55,
        parentSize: size,
        anchor: Anchor.center,
        position: size / 2,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (spent) return;
    position += direction * weapon.projectileSpeed * dt;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (spent) return;
    if (other is EnemyComponent && !other.dead) {
      spent = true;
      onHit(this, other);
      removeFromParent();
      return;
    }
    if (other is BossComponent && !other.dead) {
      spent = true;
      onHit(this, other);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final drawn = sprite;
    if (drawn != null) {
      drawn.render(canvas, size: size);
      return;
    }
    final color = weapon.id == WeaponId.fireball
        ? const Color(0xFFFF6D00)
        : const Color(0xFFB39DFF);
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 4,
      Paint()..color = color.withAlpha(70),
    );
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 6,
      Paint()..color = color,
    );
  }
}
