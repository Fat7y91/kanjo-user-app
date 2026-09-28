import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../config/game_balance.dart';
import 'player_component.dart';

class BossComponent extends PositionComponent with CollisionCallbacks {
  BossComponent({required Vector2 position, this.sprite})
      : hp = GameBalance.bossHp,
        super(
          position: position,
          size: Vector2.all(GameBalance.bossRadius * 2.2),
          anchor: Anchor.center,
          priority: 18,
        );

  final Sprite? sprite;
  double hp;
  double _aoeTimer = GameBalance.bossAoECooldown;
  double _warningTimer = 0;
  double _flash = 0;
  bool dead = false;
  Vector2? warningCenter;
  final Vector2 _dir = Vector2.zero();

  double get maxHp => GameBalance.bossHp;

  bool get isWarning => _warningTimer > 0;

  @override
  Future<void> onLoad() async {
    add(
      CircleHitbox.relative(
        0.88,
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
      hp = 0;
      dead = true;
    }
  }

  bool updateBoss(PlayerComponent player, double dt) {
    if (dead) return false;
    if (_flash > 0) _flash = math.max(0, _flash - dt);

    if (_warningTimer > 0) {
      _warningTimer = math.max(0, _warningTimer - dt);
      if (_warningTimer <= 0 && warningCenter != null) {
        final hit = (player.position - warningCenter!).length <=
            GameBalance.bossAoERadius;
        warningCenter = null;
        _aoeTimer = GameBalance.bossAoECooldown;
        return hit;
      }
      return false;
    }

    _dir
      ..setFrom(player.position)
      ..sub(position);
    if (_dir.length2 > 0.01) {
      _dir.normalize();
      position += _dir * GameBalance.bossSpeed * dt;
    }

    _aoeTimer -= dt;
    if (_aoeTimer <= 0) {
      warningCenter = player.position.clone();
      _warningTimer = GameBalance.bossAoEWarning;
    }
    return false;
  }

  bool touchesPlayer(PlayerComponent player) {
    final minDist = GameBalance.bossRadius + GameBalance.playerRadius;
    return (position - player.position).length2 <= minDist * minDist;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y - 6),
        width: size.x * 0.6,
        height: 12,
      ),
      Paint()..color = const Color(0x44000000),
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
      GameBalance.bossRadius,
      Paint()
        ..color = _flash > 0
            ? const Color(0xFFFFFFFF)
            : const Color(0xFF6A1B9A),
    );
  }
}

class BossAoeWarning extends PositionComponent {
  BossAoeWarning({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(GameBalance.bossAoERadius * 2),
          anchor: Anchor.center,
          priority: 8,
        );

  double _t = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
  }

  @override
  void render(Canvas canvas) {
    final pulse = 0.55 + 0.45 * math.sin(_t * 10);
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      GameBalance.bossAoERadius,
      Paint()
        ..color = const Color(0xFFFF1744).withAlpha((90 * pulse).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      GameBalance.bossAoERadius * 0.92,
      Paint()..color = const Color(0x33FF1744),
    );
  }
}
