import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/enemy_config.dart';
import '../models/weapon_config.dart';

/// All tunable gameplay values for Arena Survival.
abstract class GameBalance {
  static const accent = Color(0xFF9810FA);
  static const grassA = Color(0xFF3D8B4A);
  static const grassB = Color(0xFF347A41);
  static const rock = Color(0xFF8A8F7A);
  static const bush = Color(0xFF1F5C32);
  static const playerBody = Color(0xFF6C4CFF);
  static const playerAccent = Color(0xFFB39DFF);
  static const xpGem = Color(0xFF7CFFB2);
  static const hpRed = Color(0xFFE53935);
  static const hudBg = Color(0xE6FFFFFF);

  static const worldSize = 2000.0;
  static const gameDurationSeconds = 300.0;
  static const countdownSeconds = 3;
  static const chapterDurationSeconds = 60.0;
  static const chapterCount = 5;
  static const pointsPerChapter = 10;
  static const victoryCoins = 500;
  static const coinsPerKills = 10;
  static const coinsPerSeconds = 30;

  static const playerMaxHp = 100.0;
  static const playerSpeed = 180.0;
  static const playerAttackDamage = 10.0;
  static const playerAttackRange = 220.0;
  static const playerAttackCooldown = 0.8;
  static const playerPickupRadius = 70.0;
  static const playerHitIFrames = 0.8;
  static const playerKnockback = 40.0;
  static const playerRadius = 18.0;

  static const spawnMinDistance = 500.0;
  static const spawnMaxDistance = 800.0;

  static const enemyContactCooldown = 0.8;
  static const maxProjectileCount = 5;

  static const bossHp = 3000.0;
  static const bossSpeed = 40.0;
  static const bossDamage = 30.0;
  static const bossRadius = 48.0;
  static const bossAoECooldown = 4.5;
  static const bossAoERadius = 140.0;
  static const bossAoEWarning = 1.1;
  static const bossAoEDamage = 45.0;

  static const permanentMaxHpPerLevel = 5.0;
  static const permanentDamagePerLevel = 0.08;
  static const permanentSpeedPerLevel = 0.06;
  static const permanentPickupPerLevel = 0.12;
  static const permanentUpgradeBaseCost = 100;
  static const permanentUpgradeMaxLevel = 10;

  static const musicDefaultVolume = 0.7;
  static const sfxDefaultVolume = 0.9;

  static int requiredXpForLevel(int level) {
    if (level <= 1) return 10;
    return (10 + 12.5 * (level - 1) + 1.25 * (level - 1) * (level - 2))
        .round();
  }

  static WeaponConfig get magicBolt => const WeaponConfig(
        id: WeaponId.magicBolt,
        name: 'Magic Bolt',
        damage: 10,
        projectileSpeed: 500,
        range: 220,
        cooldown: 0.8,
        projectileRadius: 5,
        kind: WeaponKind.projectile,
      );

  static WeaponConfig get fireball => const WeaponConfig(
        id: WeaponId.fireball,
        name: 'Fireball',
        damage: 20,
        projectileSpeed: 350,
        range: 240,
        cooldown: 1.2,
        projectileRadius: 9,
        kind: WeaponKind.projectile,
        explodes: true,
        explosionRadius: 48,
      );

  static WeaponConfig get magicRing => const WeaponConfig(
        id: WeaponId.magicRing,
        name: 'Magic Ring',
        damage: 15,
        projectileSpeed: 0,
        range: 100,
        cooldown: 2.0,
        projectileRadius: 100,
        kind: WeaponKind.area,
      );

  static EnemyConfig get basicEnemy => const EnemyConfig(
        type: EnemyType.basic,
        maxHp: 30,
        speed: 50,
        damage: 10,
        xp: 1,
        radius: 14,
      );

  static EnemyConfig get fastEnemy => const EnemyConfig(
        type: EnemyType.fast,
        maxHp: 20,
        speed: 90,
        damage: 8,
        xp: 2,
        radius: 12,
      );

  static EnemyConfig get tankEnemy => const EnemyConfig(
        type: EnemyType.tank,
        maxHp: 100,
        speed: 30,
        damage: 20,
        xp: 5,
        radius: 22,
      );

  static SpawnWave waveForTime(double elapsedSeconds) {
    if (elapsedSeconds < 60) {
      return const SpawnWave(
        interval: 1.0,
        maxEnemies: 30,
        basicWeight: 1,
        fastWeight: 0,
        tankWeight: 0,
        hpMultiplier: 1.0,
        damageMultiplier: 1.0,
        speedMultiplier: 1.0,
      );
    }
    if (elapsedSeconds < 120) {
      return const SpawnWave(
        interval: 0.8,
        maxEnemies: 50,
        basicWeight: 3,
        fastWeight: 1,
        tankWeight: 0,
        hpMultiplier: 1.1,
        damageMultiplier: 1.05,
        speedMultiplier: 1.04,
      );
    }
    if (elapsedSeconds < 180) {
      return const SpawnWave(
        interval: 0.6,
        maxEnemies: 70,
        basicWeight: 3,
        fastWeight: 2,
        tankWeight: 1,
        hpMultiplier: 1.2,
        damageMultiplier: 1.12,
        speedMultiplier: 1.08,
      );
    }
    if (elapsedSeconds < 240) {
      return const SpawnWave(
        interval: 0.45,
        maxEnemies: 90,
        basicWeight: 2,
        fastWeight: 2,
        tankWeight: 1,
        hpMultiplier: 1.35,
        damageMultiplier: 1.2,
        speedMultiplier: 1.14,
      );
    }
    return const SpawnWave(
      interval: 0.3,
      maxEnemies: 120,
      basicWeight: 2,
      fastWeight: 2,
      tankWeight: 2,
      hpMultiplier: 1.5,
      damageMultiplier: 1.3,
      speedMultiplier: 1.2,
    );
  }

  static int chapterForTime(double elapsedSeconds) {
    if (elapsedSeconds >= gameDurationSeconds) return chapterCount + 1;
    return math.min(
      chapterCount,
      (elapsedSeconds / chapterDurationSeconds).floor() + 1,
    );
  }

  static double startTimeForCompletedChapters(int completedChapters) {
    final capped = completedChapters.clamp(0, chapterCount);
    return capped * chapterDurationSeconds;
  }

  static int coinsForRun({
    required int kills,
    required double survivalSeconds,
    required bool victory,
  }) {
    final killCoins = kills ~/ coinsPerKills;
    final timeCoins = survivalSeconds ~/ coinsPerSeconds;
    return killCoins + timeCoins + (victory ? victoryCoins : 0);
  }

  static int permanentUpgradeCost(int currentLevel) {
    return (permanentUpgradeBaseCost * math.pow(1.35, currentLevel)).round();
  }
}

class SpawnWave {
  const SpawnWave({
    required this.interval,
    required this.maxEnemies,
    required this.basicWeight,
    required this.fastWeight,
    required this.tankWeight,
    required this.hpMultiplier,
    required this.damageMultiplier,
    required this.speedMultiplier,
  });

  final double interval;
  final int maxEnemies;
  final int basicWeight;
  final int fastWeight;
  final int tankWeight;
  final double hpMultiplier;
  final double damageMultiplier;
  final double speedMultiplier;
}
