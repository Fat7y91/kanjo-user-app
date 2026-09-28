import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/bird_component.dart';
import 'components/pipe_components.dart';
import 'components/world_components.dart';
import 'flying_bird_config.dart';

enum FlyingBirdPhase { ready, playing, crashed }

class FlyingBirdGame extends FlameGame with HasCollisionDetection {
  FlyingBirdGame()
      : scoreNotifier = ValueNotifier<int>(0),
        phaseNotifier = ValueNotifier<FlyingBirdPhase>(FlyingBirdPhase.ready);

  final ValueNotifier<int> scoreNotifier;
  final ValueNotifier<FlyingBirdPhase> phaseNotifier;

  late final BirdComponent bird;
  late final PipeSpawner pipeSpawner;

  int get score => scoreNotifier.value;

  bool get isPlaying => phaseNotifier.value == FlyingBirdPhase.playing;

  @override
  Color backgroundColor() => FlyingBirdConfig.skyTop;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();

    bird = BirdComponent();
    pipeSpawner = PipeSpawner();

    world.addAll([
      SkyBackground(),
      CloudsComponent(),
      pipeSpawner,
      GroundComponent(),
      bird,
      _PlayTapArea(),
    ]);
  }

  void handleTap() {
    switch (phaseNotifier.value) {
      case FlyingBirdPhase.ready:
        start();
      case FlyingBirdPhase.playing:
        bird.flap();
      case FlyingBirdPhase.crashed:
        break;
    }
  }

  void start() {
    if (phaseNotifier.value != FlyingBirdPhase.ready) {
      return;
    }
    phaseNotifier.value = FlyingBirdPhase.playing;
    bird.flap();
  }

  void addPoint() {
    if (!isPlaying) {
      return;
    }
    scoreNotifier.value = scoreNotifier.value + 1;
  }

  void crash() {
    if (phaseNotifier.value != FlyingBirdPhase.playing) {
      return;
    }
    phaseNotifier.value = FlyingBirdPhase.crashed;
    pauseEngine();
  }

  void restart() {
    resumeEngine();
    world.children
        .whereType<PipePairComponent>()
        .toList()
        .forEach((pipe) => pipe.removeFromParent());
    pipeSpawner.reset();
    bird.reset();
    scoreNotifier.value = 0;
    phaseNotifier.value = FlyingBirdPhase.playing;
    bird.flap();
  }
}

class _PlayTapArea extends PositionComponent
    with TapCallbacks, HasGameReference<FlyingBirdGame> {
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
    game.handleTap();
  }
}
