import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'arena_survival_game.dart';
import 'arena_survival_strings.dart';
import 'config/game_balance.dart';
import 'core/game_storage.dart';
import 'widgets/arena_overlays.dart';
import 'widgets/arena_virtual_joystick.dart';

enum _MenuPage { home, upgrades, settings }

/// Full-screen Arena Survival widget.
///
/// Pass [strings] for localization, [storage] for persistence, [onBack] for
/// navigation, and [onProgressEnd] for chapter points awarded at run end.
class ArenaSurvivalGameView extends StatefulWidget {
  const ArenaSurvivalGameView({
    super.key,
    this.strings = const ArenaSurvivalStrings(),
    this.accentColor = GameBalance.accent,
    this.storage,
    this.onBack,
    this.onProgressEnd,
    this.onChapterComplete,
  });

  final ArenaSurvivalStrings strings;
  final Color accentColor;
  final ArenaGameStorage? storage;
  final VoidCallback? onBack;
  final void Function(int points)? onProgressEnd;
  final void Function(int chapter, int points)? onChapterComplete;

  @override
  State<ArenaSurvivalGameView> createState() => _ArenaSurvivalGameViewState();
}

class _ArenaSurvivalGameViewState extends State<ArenaSurvivalGameView> {
  late final ArenaSurvivalGame _game;
  final _menuPage = ValueNotifier<_MenuPage>(_MenuPage.home);
  ArenaPhase? _lastPhase;

  @override
  void initState() {
    super.initState();
    _game = ArenaSurvivalGame(
      storage: widget.storage,
      onChapterComplete: widget.onChapterComplete,
      onRunEnded: ({
        required victory,
        required points,
        required coins,
        required stats,
      }) {
        widget.onProgressEnd?.call(points);
      },
    );
    _game.phaseNotifier.addListener(_onPhaseChanged);
  }

  void _onPhaseChanged() {
    final phase = _game.phaseNotifier.value;
    if (phase == ArenaPhase.menu && _lastPhase != ArenaPhase.menu) {
      _menuPage.value = _MenuPage.home;
    }
    _lastPhase = phase;
  }

  @override
  void dispose() {
    _game.phaseNotifier.removeListener(_onPhaseChanged);
    _menuPage.dispose();
    super.dispose();
  }

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
      backgroundColor: const Color(0xFF07040E),
      body: Stack(
        fit: StackFit.expand,
        children: [
          GameWidget(game: _game),
          ValueListenableBuilder<ArenaPhase>(
            valueListenable: _game.phaseNotifier,
            builder: (context, phase, _) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  if (phase == ArenaPhase.playing ||
                      phase == ArenaPhase.countdown ||
                      phase == ArenaPhase.paused ||
                      phase == ArenaPhase.levelUp)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: ArenaHudOverlay(
                        game: _game,
                        strings: widget.strings,
                        accentColor: widget.accentColor,
                      ),
                    ),
                  if (phase == ArenaPhase.playing)
                    Positioned.directional(
                      textDirection: Directionality.of(context),
                      start: 20,
                      bottom: 20 + MediaQuery.paddingOf(context).bottom,
                      child: ArenaVirtualJoystick(
                        onChanged: _game.setMoveInput,
                      ),
                    ),
                  if (phase == ArenaPhase.countdown)
                    ArenaCountdownOverlay(
                      strings: widget.strings,
                      accentColor: widget.accentColor,
                      onDone: _game.finishCountdown,
                    ),
                  if (phase == ArenaPhase.menu)
                    ValueListenableBuilder<_MenuPage>(
                      valueListenable: _menuPage,
                      builder: (context, page, _) {
                        switch (page) {
                          case _MenuPage.upgrades:
                            return ArenaUpgradesOverlay(
                              game: _game,
                              strings: widget.strings,
                              accentColor: widget.accentColor,
                              onBack: () =>
                                  _menuPage.value = _MenuPage.home,
                            );
                          case _MenuPage.settings:
                            return ArenaSettingsOverlay(
                              game: _game,
                              strings: widget.strings,
                              accentColor: widget.accentColor,
                              onBack: () =>
                                  _menuPage.value = _MenuPage.home,
                            );
                          case _MenuPage.home:
                            return ArenaMenuOverlay(
                              game: _game,
                              strings: widget.strings,
                              accentColor: widget.accentColor,
                              onBack: _leave,
                              onUpgrades: () =>
                                  _menuPage.value = _MenuPage.upgrades,
                              onSettings: () =>
                                  _menuPage.value = _MenuPage.settings,
                            );
                        }
                      },
                    ),
                  if (phase == ArenaPhase.paused)
                    ArenaPauseOverlay(
                      game: _game,
                      strings: widget.strings,
                      accentColor: widget.accentColor,
                    ),
                  if (phase == ArenaPhase.levelUp)
                    ArenaLevelUpOverlay(
                      game: _game,
                      strings: widget.strings,
                      accentColor: widget.accentColor,
                    ),
                  if (phase == ArenaPhase.gameOver)
                    ArenaResultOverlay(
                      game: _game,
                      strings: widget.strings,
                      accentColor: widget.accentColor,
                      victory: false,
                    ),
                  if (phase == ArenaPhase.victory)
                    ArenaResultOverlay(
                      game: _game,
                      strings: widget.strings,
                      accentColor: widget.accentColor,
                      victory: true,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
