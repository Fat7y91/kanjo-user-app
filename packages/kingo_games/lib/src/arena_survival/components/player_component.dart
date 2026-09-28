import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../config/game_balance.dart';
import '../models/player_stats.dart';

class PlayerComponent extends PositionComponent with CollisionCallbacks {
  PlayerComponent({required this.stats, this.sprite})
      : super(
          size: Vector2.all(GameBalance.playerRadius * 2),
          anchor: Anchor.center,
          priority: 20,
        );

  PlayerStats stats;
  Sprite? sprite;
  final Vector2 moveInput = Vector2.zero();

  double invincibleFor = 0;
  double _regenTimer = 0;
  double _flash = 0;
  final Vector2 _move = Vector2.zero();

  @override
  Future<void> onLoad() async {
    position = Vector2.all(GameBalance.worldSize / 2);
    add(
      CircleHitbox.relative(
        0.82,
        parentSize: size,
        anchor: Anchor.center,
        position: size / 2,
      ),
    );
  }

  void resetPosition() {
    position = Vector2.all(GameBalance.worldSize / 2);
    invincibleFor = 0;
    _regenTimer = 0;
    _flash = 0;
    moveInput.setZero();
  }

  void takeDamage(double amount, {Vector2? from}) {
    if (invincibleFor > 0 || stats.hp <= 0) return;
    stats.hp = math.max(0, stats.hp - amount);
    invincibleFor = GameBalance.playerHitIFrames;
    _flash = 0.18;
    if (from != null) {
      final dir = (position - from);
      if (dir.length2 > 0.01) {
        dir.normalize();
        position += dir * GameBalance.playerKnockback;
        _clampToArena();
      }
    }
  }

  void _clampToArena() {
    final r = GameBalance.playerRadius;
    position.x = position.x.clamp(r, GameBalance.worldSize - r);
    position.y = position.y.clamp(r, GameBalance.worldSize - r);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (invincibleFor > 0) invincibleFor = math.max(0, invincibleFor - dt);
    if (_flash > 0) _flash = math.max(0, _flash - dt);

    if (stats.regenPer2Sec > 0 && stats.hp > 0 && stats.hp < stats.maxHp) {
      _regenTimer += dt;
      if (_regenTimer >= 2) {
        _regenTimer = 0;
        stats.heal(stats.regenPer2Sec);
      }
    }

    final len2 = moveInput.length2;
    if (len2 > 0.0064) {
      final len = math.sqrt(len2).clamp(0.0, 1.0);
      _move
        ..setFrom(moveInput)
        ..scale(1 / math.sqrt(len2));
      position += _move * stats.moveSpeed * len * dt;
      _clampToArena();
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final hurt = _flash > 0 || invincibleFor > 0;
    canvas.drawCircle(
      center.translate(0, 4),
      GameBalance.playerRadius * 0.9,
      Paint()..color = const Color(0x33000000),
    );
    canvas.drawCircle(
      center,
      GameBalance.playerRadius,
      Paint()
        ..color = hurt
            ? const Color(0xFFFF8A80)
            : GameBalance.playerBody,
    );
    final emblem = sprite;
    if (emblem != null) {
      emblem.render(
        canvas,
        position: Vector2(4, 4),
        size: Vector2.all(size.x - 8),
        overridePaint: hurt
            ? (Paint()..colorFilter = const ColorFilter.mode(
                Color(0xFFFFCDD2),
                BlendMode.modulate,
              ))
            : null,
      );
    }
  }
}
