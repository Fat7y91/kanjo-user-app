import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'flying_bird_config.dart';
import 'flying_bird_game.dart';
import 'flying_bird_strings.dart';
import 'widgets/flying_bird_overlays.dart';

/// Full-screen Flying Bird game widget.
///
/// Pass [strings] for localization, [onBack] for navigation, and
/// [onProgressEnd] to receive the final points when the run ends.
class FlyingBirdGameView extends StatefulWidget {
  const FlyingBirdGameView({
    super.key,
    this.strings = const FlyingBirdStrings(),
    this.accentColor = FlyingBirdConfig.accent,
    this.onBack,
    this.onProgressEnd,
  });

  final FlyingBirdStrings strings;
  final Color accentColor;
  final VoidCallback? onBack;

  /// Called once when the bird crashes, with the total points won.
  final void Function(int points)? onProgressEnd;

  @override
  State<FlyingBirdGameView> createState() => _FlyingBirdGameViewState();
}

class _FlyingBirdGameViewState extends State<FlyingBirdGameView> {
  late final FlyingBirdGame _game = FlyingBirdGame();
  FlyingBirdPhase? _lastPhase;

  @override
  void initState() {
    super.initState();
    _game.phaseNotifier.addListener(_onPhaseChanged);
  }

  void _onPhaseChanged() {
    final phase = _game.phaseNotifier.value;
    if (phase == FlyingBirdPhase.crashed &&
        _lastPhase != FlyingBirdPhase.crashed) {
      widget.onProgressEnd?.call(_game.score);
    }
    _lastPhase = phase;
  }

  @override
  void dispose() {
    _game.phaseNotifier.removeListener(_onPhaseChanged);
    super.dispose();
  }

  void _playAgain() => _game.restart();

  void _leave() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlyingBirdConfig.skyTop,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GameWidget(game: _game),
          ValueListenableBuilder<FlyingBirdPhase>(
            valueListenable: _game.phaseNotifier,
            builder: (context, phase, _) {
              return ValueListenableBuilder<int>(
                valueListenable: _game.scoreNotifier,
                builder: (context, score, _) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      if (phase == FlyingBirdPhase.playing)
                        IgnorePointer(
                          child: ScoreHud(
                            score: score,
                            strings: widget.strings,
                          ),
                        ),
                      if (phase == FlyingBirdPhase.ready)
                        StartGameOverlay(
                          strings: widget.strings,
                          accentColor: widget.accentColor,
                        ),
                      if (phase == FlyingBirdPhase.crashed)
                        GameOverOverlay(
                          score: score,
                          strings: widget.strings,
                          accentColor: widget.accentColor,
                          onPlayAgain: _playAgain,
                          onBack: _leave,
                        ),
                    ],
                  );
                },
              );
            },
          ),
          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Material(
                  color: Colors.white.withAlpha(230),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: _leave,
                    borderRadius: BorderRadius.circular(12),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
