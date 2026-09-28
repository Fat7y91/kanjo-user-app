import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../config/game_balance.dart';
import '../models/enemy_config.dart';
import 'player_component.dart';

class EnemyComponent extends PositionComponent with CollisionCallbacks {
  EnemyComponent({
    required this.config,
    required this.hpMultiplier,
    required this.damageMultiplier,
    required this.speedMultiplier,
    required Vector2 position,
    this.sprite,
  })  : hp = config.maxHp * hpMultiplier,
        super(
          position: position,
          size: Vector2.all(config.radius * 2.6),
          anchor: Anchor.center,
          priority: 10,
        );

  final EnemyConfig config;
  final double hpMultiplier;
  final double damageMultiplier;
  final double speedMultiplier;
  final Sprite? sprite;
  double hp;
  double _flash = 0;
  bool dead = false;
  final Vector2 _dir = Vector2.zero();

  double get maxHp => config.maxHp * hpMultiplier;
  double get damage => config.damage * damageMultiplier;
  double get speed => config.speed * speedMultiplier;
  int get xp => config.xp;

  @override
  Future<void> onLoad() async {
    add(
      CircleHitbox.relative(
        0.72,
        parentSize: size,
        anchor: Anchor.center,
        position: size / 2,
      )..collisionType = CollisionType.passive,
    );
  }

  void applyDamage(double amount) {
    if (dead) return;
    hp -= amount;
    _flash = 0.12;
    if (hp <= 0) {
      dead = true;
    }
  }

  void chase(PlayerComponent player, double dt) {
    if (dead) return;
    _dir
      ..setFrom(player.position)
      ..sub(position);
    if (_dir.length2 < 0.01) return;
    _dir.normalize();
    position += _dir * speed * dt;
    final r = config.radius;
    position.x = position.x.clamp(r, GameBalance.worldSize - r);
    position.y = position.y.clamp(r, GameBalance.worldSize - r);
  }

  bool touchesPlayer(PlayerComponent player) {
    final minDist = config.radius + GameBalance.playerRadius;
    return (position - player.position).length2 <= minDist * minDist;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_flash > 0) _flash = math.max(0, _flash - dt);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y - 4),
        width: size.x * 0.55,
        height: 8,
      ),
      Paint()..color = const Color(0x33000000),
    );
    final drawn = sprite;
    if (drawn != null) {
      drawn.render(
        canvas,
        size: size,
        overridePaint: _flash > 0
            ? (Paint()
              ..colorFilter = const ColorFilter.mode(
                Color(0xFFFFFFFF),
                BlendMode.srcATop,
              ))
            : null,
      );
      return;
    }
    final center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(
      center,
      config.radius,
      Paint()..color = _flash > 0 ? const Color(0xFFFFFFFF) : const Color(0xFF6D4C41),
    );
  }
}
