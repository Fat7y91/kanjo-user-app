import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'components/bullet_component.dart';
import 'components/enemy_component.dart';
import 'components/gun_component.dart';
import 'components/world_components.dart';
import 'gun_shooter_config.dart';

enum GunShooterPhase { ready, playing, gameOver }

class GunShooterGame extends FlameGame with HasCollisionDetection {
  GunShooterGame()
      : scoreNotifier = ValueNotifier<int>(0),
        livesNotifier = ValueNotifier<int>(GunShooterConfig.maxLives),
        phaseNotifier =
            ValueNotifier<GunShooterPhase>(GunShooterPhase.ready);

  final ValueNotifier<int> scoreNotifier;
  final ValueNotifier<int> livesNotifier;
  final ValueNotifier<GunShooterPhase> phaseNotifier;

  late final GunComponent gun;
  late final EnemySpawner enemySpawner;

  double _fireCooldown = 0;
  Vector2 _aimPoint = Vector2.zero();

  int get score => scoreNotifier.value;

  bool get isPlaying => phaseNotifier.value == GunShooterPhase.playing;

  @override
  Color backgroundColor() => GunShooterConfig.skyTop;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();

    gun = GunComponent();
    enemySpawner = EnemySpawner();
    _aimPoint = Vector2(size.x / 2, size.y * 0.35);

    world.addAll([
      ShooterSkyBackground(),
      enemySpawner,
      GroundStrip(),
      gun,
      _PlayTapArea(),
    ]);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_aimPoint == Vector2.zero()) {
      _aimPoint = Vector2(size.x / 2, size.y * 0.35);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_fireCooldown > 0) {
      _fireCooldown = math.max(0, _fireCooldown - dt);
    }
  }

  void handleTap(Vector2 point) {
    switch (phaseNotifier.value) {
      case GunShooterPhase.ready:
        start();
        _aimAt(point);
        shoot();
      case GunShooterPhase.playing:
        _aimAt(point);
        shoot();
      case GunShooterPhase.gameOver:
        break;
    }
  }

  void _aimAt(Vector2 point) {
    _aimPoint = point.clone();
    gun.aimAt(point);
  }

  void start() {
    if (phaseNotifier.value != GunShooterPhase.ready) {
      return;
    }
    phaseNotifier.value = GunShooterPhase.playing;
  }

  void shoot() {
    if (!isPlaying || _fireCooldown > 0) {
      return;
    }
    final origin = gun.muzzleWorldPosition;
    final direction = (_aimPoint - origin);
    if (direction.length2 < 4) {
      return;
    }
    direction.normalize();
    world.add(
      BulletComponent(
        position: origin,
        direction: direction,
      ),
    );
    _fireCooldown = GunShooterConfig.fireCooldown;
    gun.flash();
  }

  void addPoint() {
    if (!isPlaying) {
      return;
    }
    scoreNotifier.value =
        scoreNotifier.value + GunShooterConfig.pointsPerHit;
  }

  void enemyReachedBottom() {
    if (!isPlaying) {
      return;
    }
    livesNotifier.value = math.max(0, livesNotifier.value - 1);
    if (livesNotifier.value <= 0) {
      endGame();
    }
  }

  void endGame() {
    if (phaseNotifier.value != GunShooterPhase.playing) {
      return;
    }
    phaseNotifier.value = GunShooterPhase.gameOver;
    pauseEngine();
  }

  void restart() {
    resumeEngine();
    world.children.whereType<BulletComponent>().toList().forEach(
          (b) => b.removeFromParent(),
        );
    world.children.whereType<EnemyComponent>().toList().forEach(
          (e) => e.removeFromParent(),
        );
    enemySpawner.reset();
    scoreNotifier.value = 0;
    livesNotifier.value = GunShooterConfig.maxLives;
    _fireCooldown = 0;
    _aimPoint = Vector2(size.x / 2, size.y * 0.35);
    gun.reset();
    gun.aimAt(_aimPoint);
    phaseNotifier.value = GunShooterPhase.playing;
  }
}

class _PlayTapArea extends PositionComponent
    with TapCallbacks, HasGameReference<GunShooterGame> {
  _PlayTapArea() : super(priority: 100);

  @override
  Future<void> onLoad() async {
    size = game.size.clone();
    position = Vector2.zero();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size.clone();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.handleTap(event.localPosition);
  }
}
