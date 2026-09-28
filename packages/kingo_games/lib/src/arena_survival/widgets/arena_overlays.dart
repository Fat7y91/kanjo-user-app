import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../config/arena_assets.dart';

import '../arena_survival_game.dart';
import '../arena_survival_strings.dart';
import '../config/game_balance.dart';
import '../models/save_data.dart';
import '../models/upgrade.dart';

String formatArenaTime(double seconds) {
  final total = seconds.floor().clamp(0, 99 * 60);
  final m = (total ~/ 60).toString().padLeft(2, '0');
  final s = (total % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

class ArenaHudOverlay extends StatelessWidget {
  const ArenaHudOverlay({
    super.key,
    required this.game,
    required this.strings,
    this.accentColor = GameBalance.accent,
  });

  final ArenaSurvivalGame game;
  final ArenaSurvivalStrings strings;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.hudTick,
      builder: (context, _, __) {
        final stats = game.stats;
        final run = game.run;
        final xpNeed = GameBalance.requiredXpForLevel(run.level);
        final xpT = xpNeed == 0 ? 0.0 : (run.xp / xpNeed).clamp(0.0, 1.0);
        final boss = game.boss;
        return SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                  Row(
                    children: [
                      _HudCard(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              ArenaAssets.heart,
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${stats.hp.floor()} / ${stats.maxHp.floor()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF161D31),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _HudCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${strings.level} ${run.level}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF161D31),
                                ),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: xpT,
                                  minHeight: 8,
                                  backgroundColor: const Color(0xFFE0E0E0),
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _HudCard(
                        child: Text(
                          '⏱ ${formatArenaTime(run.elapsed)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF161D31),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.white.withAlpha(230),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: game.pauseGame,
                          borderRadius: BorderRadius.circular(12),
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(Icons.pause_rounded),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (boss != null) ...[
                    const SizedBox(height: 8),
                    _HudCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Arena Guardian',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6A1B9A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (boss.hp / boss.maxHp).clamp(0, 1),
                              minHeight: 10,
                              backgroundColor: const Color(0xFFE0E0E0),
                              color: const Color(0xFFE53935),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: _HudCard(
                      child: Text(
                        '${strings.kills}: ${run.kills}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF161D31),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        );
      },
    );
  }
}

class _HudCard extends StatelessWidget {
  const _HudCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class ArenaMenuOverlay extends StatefulWidget {
  const ArenaMenuOverlay({
    super.key,
    required this.game,
    required this.strings,
    required this.onBack,
    required this.onUpgrades,
    required this.onSettings,
    this.accentColor = GameBalance.accent,
  });

  final ArenaSurvivalGame game;
  final ArenaSurvivalStrings strings;
  final VoidCallback onBack;
  final VoidCallback onUpgrades;
  final VoidCallback onSettings;
  final Color accentColor;

  @override
  State<ArenaMenuOverlay> createState() => _ArenaMenuOverlayState();
}

class _ArenaMenuOverlayState extends State<ArenaMenuOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ArenaSaveData>(
      valueListenable: widget.game.saveNotifier,
      builder: (context, save, _) {
        final canContinue = save.completedChapters > 0;
        return AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) {
            final t = _pulse.value;
            return Stack(
              fit: StackFit.expand,
              children: [
                _ArenaMenuBackdrop(accent: widget.accentColor, pulse: t),
                _ArenaMenuDecor(pulse: t),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                    child: Column(
                      children: [
                        _ArenaMenuTopBar(
                          coinsLabel: widget.strings.coins,
                          coins: save.coins,
                          onBack: widget.onBack,
                          onSettings: widget.onSettings,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              children: [
                                const SizedBox(height: 12),
                                _ArenaMenuHero(
                                  accent: widget.accentColor,
                                  pulse: t,
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  widget.strings.title.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.4,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: widget.accentColor.withAlpha(160),
                                        blurRadius: 18,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.strings.subtitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.35,
                                    color: Colors.white.withAlpha(200),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _ArenaStatChip(
                                        icon: Icons.flag_rounded,
                                        label: widget.strings.chapter,
                                        value: '${save.completedChapters + 1}',
                                        accent: widget.accentColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _ArenaStatChip(
                                        icon: Icons.timer_outlined,
                                        label: widget.strings.bestTime,
                                        value: formatArenaTime(
                                          save.bestSurvivalSeconds,
                                        ),
                                        accent: widget.accentColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _ArenaStatChip(
                                        icon: Icons.sports_kabaddi_rounded,
                                        label: widget.strings.kills,
                                        value: '${save.totalKills}',
                                        accent: widget.accentColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),
                                _ArenaPlayButton(
                                  label: widget.strings.play,
                                  accent: widget.accentColor,
                                  pulse: t,
                                  onTap: () => widget.game
                                      .startRun(continueChapters: false),
                                ),
                                if (canContinue) ...[
                                  const SizedBox(height: 12),
                                  _ArenaGhostButton(
                                    icon: Icons.play_circle_outline_rounded,
                                    label:
                                        '${widget.strings.continueRun} ${save.completedChapters + 1}',
                                    accent: widget.accentColor,
                                    onTap: () => widget.game
                                        .startRun(continueChapters: true),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _ArenaActionTile(
                                icon: Icons.auto_awesome_rounded,
                                label: widget.strings.upgrades,
                                accent: widget.accentColor,
                                onTap: widget.onUpgrades,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ArenaActionTile(
                                icon: Icons.tune_rounded,
                                label: widget.strings.settings,
                                accent: widget.accentColor,
                                onTap: widget.onSettings,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ArenaMenuBackdrop extends StatelessWidget {
  const _ArenaMenuBackdrop({required this.accent, required this.pulse});

  final Color accent;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.35),
          radius: 1.15 + (0.08 * pulse),
          colors: [
            accent.withAlpha(70),
            const Color(0xFF12081F),
            const Color(0xFF07040E),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
    );
  }
}

class _ArenaMenuDecor extends StatelessWidget {
  const _ArenaMenuDecor({required this.pulse});

  final double pulse;

  @override
  Widget build(BuildContext context) {
    final float = (pulse - 0.5) * 12;
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 90 + float,
            left: -10,
            child: Opacity(
              opacity: 0.22,
              child: Image.asset(
                ArenaAssets.zombieFast,
                width: 92,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
          Positioned(
            top: 130 - float,
            right: -16,
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                ArenaAssets.zombieTank,
                width: 108,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
          Positioned(
            bottom: 150 + float,
            left: 18,
            child: Opacity(
              opacity: 0.28,
              child: Image.asset(
                ArenaAssets.fireball,
                width: 42,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
          Positioned(
            bottom: 180 - float,
            right: 24,
            child: Opacity(
              opacity: 0.28,
              child: Image.asset(
                ArenaAssets.lightning,
                width: 40,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(20),
                    Colors.transparent,
                    const Color(0xFF07040E).withAlpha(180),
                  ],
                  stops: const [0, 0.35, 1],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArenaMenuTopBar extends StatelessWidget {
  const _ArenaMenuTopBar({
    required this.coinsLabel,
    required this.coins,
    required this.onBack,
    required this.onSettings,
  });

  final String coinsLabel;
  final int coins;
  final VoidCallback onBack;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ArenaCircleButton(
          icon: Icons.arrow_back_rounded,
          onTap: onBack,
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(18),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withAlpha(28)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.monetization_on_rounded,
                  size: 18, color: const Color(0xFFFFD54F)),
              const SizedBox(width: 6),
              Text(
                '$coins',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                coinsLabel,
                style: TextStyle(
                  color: Colors.white.withAlpha(170),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _ArenaCircleButton(
          icon: Icons.settings_rounded,
          onTap: onSettings,
        ),
      ],
    );
  }
}

class _ArenaCircleButton extends StatelessWidget {
  const _ArenaCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withAlpha(18),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _ArenaMenuHero extends StatelessWidget {
  const _ArenaMenuHero({required this.accent, required this.pulse});

  final Color accent;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    final glow = 18 + (22 * pulse);
    return SizedBox(
      height: 168,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 148 + (10 * pulse),
            height: 148 + (10 * pulse),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withAlpha(90 + (50 * pulse).round()),
                  blurRadius: glow,
                  spreadRadius: 6 + (8 * pulse),
                ),
              ],
              gradient: RadialGradient(
                colors: [
                  accent.withAlpha(70),
                  accent.withAlpha(10),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            width: 124,
            height: 124,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A1028).withAlpha(220),
              border: Border.all(color: accent.withAlpha(140), width: 2),
            ),
            child: Image.asset(
              ArenaAssets.zombieBoss,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArenaStatChip extends StatelessWidget {
  const _ArenaStatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(28)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withAlpha(160),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArenaPlayButton extends StatelessWidget {
  const _ArenaPlayButton({
    required this.label,
    required this.accent,
    required this.pulse,
    required this.onTap,
  });

  final String label;
  final Color accent;
  final double pulse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: accent.withAlpha(70 + (50 * pulse).round()),
            blurRadius: 18 + (10 * pulse),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent,
                  Color.lerp(accent, const Color(0xFF6E11B0), 0.55)!,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 30),
                const SizedBox(width: 6),
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArenaGhostButton extends StatelessWidget {
  const _ArenaGhostButton({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withAlpha(12),
            border: Border.all(color: accent.withAlpha(140), width: 1.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withAlpha(230),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArenaActionTile extends StatelessWidget {
  const _ArenaActionTile({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withAlpha(14),
            border: Border.all(color: Colors.white.withAlpha(28)),
          ),
          child: Column(
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ArenaUpgradesOverlay extends StatelessWidget {
  const ArenaUpgradesOverlay({
    super.key,
    required this.game,
    required this.strings,
    required this.onBack,
    this.accentColor = GameBalance.accent,
  });

  final ArenaSurvivalGame game;
  final ArenaSurvivalStrings strings;
  final VoidCallback onBack;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ArenaSaveData>(
      valueListenable: game.saveNotifier,
      builder: (context, save, _) {
        return ColoredBox(
          color: const Color(0xF2161D31),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          strings.upgrades,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  Text(
                    '${strings.coins}: ${save.coins}',
                    style: const TextStyle(
                      color: Color(0xFFFFE082),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        _PermUpgradeTile(
                          title: strings.hp,
                          level: save.permanentMaxHpLevel,
                          effect:
                              '+${(save.permanentMaxHpLevel * GameBalance.permanentMaxHpPerLevel).toStringAsFixed(0)} HP',
                          strings: strings,
                          accentColor: accentColor,
                          onUpgrade: () => game.buyPermanentUpgrade('hp'),
                        ),
                        _PermUpgradeTile(
                          title: strings.damage,
                          level: save.permanentDamageLevel,
                          effect:
                              '+${(save.permanentDamageLevel * GameBalance.permanentDamagePerLevel * 100).toStringAsFixed(0)}%',
                          strings: strings,
                          accentColor: accentColor,
                          onUpgrade: () => game.buyPermanentUpgrade('damage'),
                        ),
                        _PermUpgradeTile(
                          title: strings.moveSpeed,
                          level: save.permanentSpeedLevel,
                          effect:
                              '+${(save.permanentSpeedLevel * GameBalance.permanentSpeedPerLevel * 100).toStringAsFixed(0)}%',
                          strings: strings,
                          accentColor: accentColor,
                          onUpgrade: () => game.buyPermanentUpgrade('speed'),
                        ),
                        _PermUpgradeTile(
                          title: strings.pickupRadius,
                          level: save.permanentPickupLevel,
                          effect:
                              '+${(save.permanentPickupLevel * GameBalance.permanentPickupPerLevel * 100).toStringAsFixed(0)}%',
                          strings: strings,
                          accentColor: accentColor,
                          onUpgrade: () => game.buyPermanentUpgrade('pickup'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PermUpgradeTile extends StatelessWidget {
  const _PermUpgradeTile({
    required this.title,
    required this.level,
    required this.effect,
    required this.strings,
    required this.accentColor,
    required this.onUpgrade,
  });

  final String title;
  final int level;
  final String effect;
  final ArenaSurvivalStrings strings;
  final Color accentColor;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final maxed = level >= GameBalance.permanentUpgradeMaxLevel;
    final cost = GameBalance.permanentUpgradeCost(level);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  '${strings.level} $level  •  $effect',
                  style: const TextStyle(color: Color(0xCCFFFFFF)),
                ),
                const SizedBox(height: 4),
                Text(
                  maxed ? strings.maxLevel : '${strings.cost}: $cost',
                  style: const TextStyle(color: Color(0xFFFFE082)),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: maxed ? null : onUpgrade,
            style: FilledButton.styleFrom(backgroundColor: accentColor),
            child: Text(strings.upgrade),
          ),
        ],
      ),
    );
  }
}

class ArenaSettingsOverlay extends StatelessWidget {
  const ArenaSettingsOverlay({
    super.key,
    required this.game,
    required this.strings,
    required this.onBack,
    this.accentColor = GameBalance.accent,
  });

  final ArenaSurvivalGame game;
  final ArenaSurvivalStrings strings;
  final VoidCallback onBack;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ArenaSaveData>(
      valueListenable: game.saveNotifier,
      builder: (context, save, _) {
        return ColoredBox(
          color: const Color(0xF2161D31),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          strings.settings,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(strings.music,
                      style: const TextStyle(color: Colors.white)),
                  Slider(
                    value: save.musicVolume.clamp(0, 1),
                    activeColor: accentColor,
                    onChanged: (v) => game.updateVolumes(music: v),
                  ),
                  Text(strings.sfx,
                      style: const TextStyle(color: Colors.white)),
                  Slider(
                    value: save.sfxVolume.clamp(0, 1),
                    activeColor: accentColor,
                    onChanged: (v) => game.updateVolumes(sfx: v),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${strings.highestLevel}: ${save.highestLevel}',
                    style: const TextStyle(color: Color(0xCCFFFFFF)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${strings.totalKills}: ${save.totalKills}',
                    style: const TextStyle(color: Color(0xCCFFFFFF)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ArenaPauseOverlay extends StatelessWidget {
  const ArenaPauseOverlay({
    super.key,
    required this.game,
    required this.strings,
    this.accentColor = GameBalance.accent,
  });

  final ArenaSurvivalGame game;
  final ArenaSurvivalStrings strings;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withAlpha(150),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(strings.gamePaused,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                _MenuButton(
                    label: strings.resume,
                    color: accentColor,
                    onTap: game.resumeGame),
                const SizedBox(height: 10),
                _MenuButton(
                  label: strings.restart,
                  outlined: true,
                  color: accentColor,
                  onTap: () => game.startRun(continueChapters: true),
                ),
                const SizedBox(height: 10),
                _MenuButton(
                  label: strings.mainMenu,
                  outlined: true,
                  color: accentColor,
                  onTap: game.returnToMenu,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ArenaLevelUpOverlay extends StatelessWidget {
  const ArenaLevelUpOverlay({
    super.key,
    required this.game,
    required this.strings,
    this.accentColor = GameBalance.accent,
  });

  final ArenaSurvivalGame game;
  final ArenaSurvivalStrings strings;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<RunUpgrade>>(
      valueListenable: game.pendingUpgrades,
      builder: (context, upgrades, _) {
        return ColoredBox(
          color: Colors.black.withAlpha(160),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Spacer(),
                  Text(strings.levelUp,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(strings.chooseUpgrade,
                      style: const TextStyle(color: Color(0xCCFFFFFF))),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      for (var i = 0; i < upgrades.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: _UpgradeCard(
                            upgrade: upgrades[i],
                            accentColor: accentColor,
                            onTap: () => game.applyUpgrade(upgrades[i]),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard({
    required this.upgrade,
    required this.accentColor,
    required this.onTap,
  });

  final RunUpgrade upgrade;
  final Color accentColor;
  final VoidCallback onTap;

  Widget _upgradeIcon(RunUpgrade upgrade) {
    final asset = upgrade.asset;
    if (asset == null) {
      return Text(upgrade.icon, style: const TextStyle(fontSize: 28));
    }
    if (asset.endsWith('.svg')) {
      return SvgPicture.asset(asset, width: 36, height: 36);
    }
    return Image.asset(asset, width: 36, height: 36, filterQuality: FilterQuality.medium);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _upgradeIcon(upgrade),
              const SizedBox(height: 8),
              Text(upgrade.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: accentColor)),
              const SizedBox(height: 6),
              Text(
                upgrade.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Color(0xFF656969)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ArenaResultOverlay extends StatelessWidget {
  const ArenaResultOverlay({
    super.key,
    required this.game,
    required this.strings,
    required this.victory,
    this.accentColor = GameBalance.accent,
  });

  final ArenaSurvivalGame game;
  final ArenaSurvivalStrings strings;
  final bool victory;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final run = game.run;
    final coins = game.lastCoins;
    final points = game.lastPoints;
    return ColoredBox(
      color: Colors.black.withAlpha(160),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  victory ? strings.victory : strings.gameOver,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800),
                ),
                if (victory) ...[
                  const SizedBox(height: 4),
                  Text(strings.bossDefeated,
                      style: TextStyle(
                          color: accentColor, fontWeight: FontWeight.w700)),
                ],
                const SizedBox(height: 16),
                _stat(strings.survivalTime, formatArenaTime(run.elapsed)),
                _stat(strings.level, '${run.level}'),
                _stat(strings.kills, '${run.kills}'),
                _stat(strings.coinsEarned, '+$coins'),
                if (points > 0)
                  _stat(strings.pointsWon(points), ''),
                const SizedBox(height: 20),
                _MenuButton(
                  label: strings.playAgain,
                  color: accentColor,
                  onTap: () => game.startRun(continueChapters: true),
                ),
                const SizedBox(height: 10),
                _MenuButton(
                  label: strings.mainMenu,
                  outlined: true,
                  color: accentColor,
                  onTap: game.returnToMenu,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (value.isNotEmpty)
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class ArenaCountdownOverlay extends StatefulWidget {
  const ArenaCountdownOverlay({
    super.key,
    required this.onDone,
    required this.strings,
    this.accentColor = GameBalance.accent,
  });

  final VoidCallback onDone;
  final ArenaSurvivalStrings strings;
  final Color accentColor;

  @override
  State<ArenaCountdownOverlay> createState() => _ArenaCountdownOverlayState();
}

class _ArenaCountdownOverlayState extends State<ArenaCountdownOverlay> {
  int _value = GameBalance.countdownSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_value <= 1) {
        timer.cancel();
        widget.onDone();
        return;
      }
      setState(() => _value -= 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Text(
          _value > 0 ? '$_value' : widget.strings.countdownGo,
          style: TextStyle(
            fontSize: 88,
            fontWeight: FontWeight.w900,
            color: widget.accentColor,
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: color, width: 2),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
