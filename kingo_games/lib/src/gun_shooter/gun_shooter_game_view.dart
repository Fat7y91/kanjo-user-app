import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'gun_shooter_config.dart';
import 'gun_shooter_game.dart';
import 'gun_shooter_strings.dart';
import 'widgets/gun_shooter_overlays.dart';

/// Full-screen gun shooter game widget.
class GunShooterGameView extends StatefulWidget {
  const GunShooterGameView({
    super.key,
    this.strings = const GunShooterStrings(),
    this.accentColor = GunShooterConfig.accent,
    this.onBack,
    this.onProgressEnd,
  });

  final GunShooterStrings strings;
  final Color accentColor;
  final VoidCallback? onBack;

  /// Called once when the run ends, with the total points won.
  final void Function(int points)? onProgressEnd;

  @override
  State<GunShooterGameView> createState() => _GunShooterGameViewState();
}

class _GunShooterGameViewState extends State<GunShooterGameView> {
  late final GunShooterGame _game = GunShooterGame();
  GunShooterPhase? _lastPhase;

  @override
  void initState() {
    super.initState();
    _game.phaseNotifier.addListener(_onPhaseChanged);
  }

  void _onPhaseChanged() {
    final phase = _game.phaseNotifier.value;
    if (phase == GunShooterPhase.gameOver &&
        _lastPhase != GunShooterPhase.gameOver) {
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
      backgroundColor: GunShooterConfig.skyTop,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GameWidget(game: _game),
          ValueListenableBuilder<GunShooterPhase>(
            valueListenable: _game.phaseNotifier,
            builder: (context, phase, _) {
              return ValueListenableBuilder<int>(
                valueListenable: _game.scoreNotifier,
                builder: (context, score, _) {
                  return ValueListenableBuilder<int>(
                    valueListenable: _game.livesNotifier,
                    builder: (context, lives, _) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          if (phase == GunShooterPhase.playing)
                            IgnorePointer(
                              child: ShooterHud(
                                score: score,
                                lives: lives,
                                strings: widget.strings,
                              ),
                            ),
                          if (phase == GunShooterPhase.ready)
                            StartShooterOverlay(
                              strings: widget.strings,
                              accentColor: widget.accentColor,
                            ),
                          if (phase == GunShooterPhase.gameOver)
                            ShooterGameOverOverlay(
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
