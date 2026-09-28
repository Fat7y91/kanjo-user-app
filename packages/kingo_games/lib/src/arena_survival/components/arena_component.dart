import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../config/game_balance.dart';

class ArenaComponent extends PositionComponent {
  ArenaComponent({this.palmSprite})
      : super(
          size: Vector2.all(GameBalance.worldSize),
          position: Vector2.zero(),
          priority: 0,
        );

  final Sprite? palmSprite;
  final List<_Deco> _rocks = [];
  final List<_Deco> _bushes = [];

  @override
  Future<void> onLoad() async {
    final random = math.Random(42);
    for (var i = 0; i < 40; i++) {
      _rocks.add(
        _Deco(
          Offset(
            80 + random.nextDouble() * (size.x - 160),
            80 + random.nextDouble() * (size.y - 160),
          ),
          8 + random.nextDouble() * 14,
        ),
      );
    }
    for (var i = 0; i < 28; i++) {
      _bushes.add(
        _Deco(
          Offset(
            80 + random.nextDouble() * (size.x - 160),
            80 + random.nextDouble() * (size.y - 160),
          ),
          16 + random.nextDouble() * 18,
        ),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = GameBalance.grassA);
    const tile = 80.0;
    final alt = Paint()..color = GameBalance.grassB.withAlpha(70);
    for (var y = 0.0; y < size.y; y += tile) {
      for (var x = 0.0; x < size.x; x += tile) {
        if (((x + y) / tile).floor().isEven) {
          canvas.drawRect(Rect.fromLTWH(x, y, tile, tile), alt);
        }
      }
    }
    canvas.drawRect(
      size.toRect().inflate(-4),
      Paint()
        ..color = const Color(0xFF1B3D24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );
    final palm = palmSprite;
    for (final bush in _bushes) {
      if (palm != null) {
        final treeSize = bush.radius * 3.2;
        palm.render(
          canvas,
          position: Vector2(
            bush.offset.dx - treeSize / 2,
            bush.offset.dy - treeSize / 2,
          ),
          size: Vector2.all(treeSize),
        );
      } else {
        canvas.drawCircle(
          bush.offset,
          bush.radius,
          Paint()..color = GameBalance.bush,
        );
      }
    }
    for (final rock in _rocks) {
      canvas.drawOval(
        Rect.fromCenter(
          center: rock.offset,
          width: rock.radius * 1.6,
          height: rock.radius,
        ),
        Paint()..color = GameBalance.rock,
      );
    }
  }
}

class _Deco {
  const _Deco(this.offset, this.radius);
  final Offset offset;
  final double radius;
}
