import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../flying_bird_config.dart';
import '../flying_bird_game.dart';
import 'world_components.dart';

class PipeSpawner extends Component with HasGameReference<FlyingBirdGame> {
  static const _firstSpawnDelay = 0.7;
  double _timer = FlyingBirdConfig.spawnInterval - _firstSpawnDelay;

  void reset() {
    _timer = FlyingBirdConfig.spawnInterval - _firstSpawnDelay;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isPlaying) {
      return;
    }
    _timer += dt;
    if (_timer >= FlyingBirdConfig.spawnInterval) {
      _timer = 0;
      _spawn();
    }
  }

  void _spawn() {
    final gap = FlyingBirdConfig.pipeGap;
    final minGapY = FlyingBirdConfig.groundHeight + gap / 2 + 36;
    final maxGapY = game.size.y - FlyingBirdConfig.groundHeight - gap / 2 - 36;
    final span = math.max(20.0, maxGapY - minGapY);
    final gapY = minGapY + math.Random().nextDouble() * span;
    game.world.add(PipePairComponent(gapY: gapY, gapSize: gap));
  }
}

class PipePairComponent extends PositionComponent
    with HasGameReference<FlyingBirdGame> {
  PipePairComponent({
    required this.gapY,
    required this.gapSize,
  }) : super(priority: 5);

  final double gapY;
  final double gapSize;
  bool _scored = false;

  @override
  Future<void> onLoad() async {
    final pipeWidth = FlyingBirdConfig.pipeWidth;
    size = Vector2(pipeWidth, game.size.y);
    position = Vector2(game.size.x + 8, 0);

    final topHeight = math.max(40.0, gapY - gapSize / 2);
    final bottomY = gapY + gapSize / 2;
    final bottomHeight = math.max(
      40.0,
      game.size.y - bottomY - FlyingBirdConfig.groundHeight,
    );

    add(
      PipeComponent(isTop: true)
        ..size = Vector2(pipeWidth, topHeight)
        ..position = Vector2.zero(),
    );
    add(
      PipeComponent(isTop: false)
        ..size = Vector2(pipeWidth, bottomHeight)
        ..position = Vector2(0, bottomY),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isPlaying) {
      return;
    }
    x -= FlyingBirdConfig.pipeSpeed * dt;
    if (!_scored && x + size.x < game.bird.x) {
      _scored = true;
      game.addPoint();
    }
    if (x + size.x < -40) {
      removeFromParent();
    }
  }
}

class PipeComponent extends PositionComponent with Obstacle {
  PipeComponent({required this.isTop});

  final bool isTop;

  @override
  Future<void> onLoad() async {
    add(
      RectangleHitbox()..collisionType = CollisionType.passive,
    );
  }

  @override
  void render(Canvas canvas) {
    final body = Rect.fromLTWH(4, 0, size.x - 8, size.y);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(6)),
      Paint()..color = FlyingBirdConfig.pipeGreen,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(6)),
      Paint()
        ..color = FlyingBirdConfig.pipeDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawRect(
      Rect.fromLTWH(10, 8, 8, math.max(0, size.y - 16)),
      Paint()..color = FlyingBirdConfig.pipeLight.withAlpha(140),
    );

    final capHeight = 28.0;
    final capRect = isTop
        ? Rect.fromLTWH(0, size.y - capHeight, size.x, capHeight)
        : Rect.fromLTWH(0, 0, size.x, capHeight);
    canvas.drawRRect(
      RRect.fromRectAndRadius(capRect, const Radius.circular(8)),
      Paint()..color = FlyingBirdConfig.pipeDark,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(capRect, const Radius.circular(8)),
      Paint()
        ..color = FlyingBirdConfig.pipeLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }
}
