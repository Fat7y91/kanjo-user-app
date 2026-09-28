import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../config/game_balance.dart';
import 'player_component.dart';

class XpGemComponent extends SpriteComponent with CollisionCallbacks {
  XpGemComponent({
    required Vector2 position,
    required this.xp,
    Sprite? sprite,
    this.fallbackColor = GameBalance.xpGem,
  }) : super(
          position: position,
          size: Vector2.all(22),
          anchor: Anchor.center,
          sprite: sprite,
          priority: 12,
        );

  final int xp;
  final Color fallbackColor;
  bool _collecting = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      CircleHitbox.relative(
        0.7,
        parentSize: size,
        anchor: Anchor.center,
        position: size / 2,
      )..collisionType = CollisionType.passive,
    );
  }

  void pullToward(PlayerComponent player, double dt) {
    if (_collecting) return;
    final delta = player.position - position;
    final dist2 = delta.length2;
    final magnet = player.stats.pickupRadius;
    if (dist2 <= magnet * magnet) {
      if (dist2 < 18 * 18) {
        _collecting = true;
        return;
      }
      delta.normalize();
      position += delta * 320 * dt;
    }
  }

  bool get readyToCollect => _collecting;

  @override
  void render(Canvas canvas) {
    if (sprite != null) {
      super.render(canvas);
      return;
    }
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      Paint()..color = fallbackColor,
    );
  }
}
