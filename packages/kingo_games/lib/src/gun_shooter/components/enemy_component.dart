import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../gun_shooter_config.dart';
import '../gun_shooter_game.dart';

class EnemySpawner extends Component with HasGameReference<GunShooterGame> {
  static const _firstSpawnDelay = 0.55;
  double _timer = GunShooterConfig.spawnInterval - _firstSpawnDelay;

  void reset() {
    _timer = GunShooterConfig.spawnInterval - _firstSpawnDelay;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isPlaying) {
      return;
    }
    _timer += dt;
    if (_timer >= GunShooterConfig.spawnInterval) {
      _timer = 0;
      _spawn();
    }
  }

  void _spawn() {
    final random = math.Random();
    final margin = GunShooterConfig.enemySize;
    final x = margin + random.nextDouble() * (game.size.x - margin * 2);
    final speedBoost = (game.score * 2.5).clamp(0, 120).toDouble();
    game.world.add(
      EnemyComponent(
        position: Vector2(x, -GunShooterConfig.enemySize),
        speed: GunShooterConfig.enemyBaseSpeed + speedBoost,
      ),
    );
  }
}

class EnemyComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<GunShooterGame> {
  EnemyComponent({
    required Vector2 position,
    required this.speed,
  }) : super(
          position: position,
          size: Vector2.all(GunShooterConfig.enemySize),
          anchor: Anchor.center,
          priority: 10,
        );

  final double speed;
  bool _settled = false;

  @override
  Future<void> onLoad() async {
    add(
      CircleHitbox.relative(
        0.78,
        parentSize: size,
        anchor: Anchor.center,
        position: size / 2,
      )..collisionType = CollisionType.passive,
    );
  }

  void hit() {
    if (_settled) {
      return;
    }
    _settled = true;
    game.addPoint();
    removeFromParent();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isPlaying || _settled) {
      return;
    }
    y += speed * dt;
    final bottomLimit =
        game.size.y - GunShooterConfig.groundHeight - size.y * 0.2;
    if (y >= bottomLimit) {
      _settled = true;
      game.enemyReachedBottom();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(
      center,
      size.x / 2,
      Paint()..color = GunShooterConfig.enemyBody,
    );
    canvas.drawCircle(
      center,
      size.x / 2,
      Paint()
        ..color = GunShooterConfig.enemyDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      Offset(center.dx - 8, center.dy - 4),
      4.5,
      Paint()..color = GunShooterConfig.enemyEye,
    );
    canvas.drawCircle(
      Offset(center.dx + 8, center.dy - 4),
      4.5,
      Paint()..color = GunShooterConfig.enemyEye,
    );
    canvas.drawCircle(
      Offset(center.dx - 8, center.dy - 4),
      2,
      Paint()..color = GunShooterConfig.enemyDark,
    );
    canvas.drawCircle(
      Offset(center.dx + 8, center.dy - 4),
      2,
      Paint()..color = GunShooterConfig.enemyDark,
    );
  }
}
