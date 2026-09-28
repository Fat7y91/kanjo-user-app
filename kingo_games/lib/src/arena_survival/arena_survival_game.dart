import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'components/arena_component.dart';
import 'components/boss_component.dart';
import 'components/enemy_component.dart';
import 'components/player_component.dart';
import 'components/projectile_component.dart';
import 'components/vfx_components.dart';
import 'components/xp_gem_component.dart';
import 'config/arena_assets.dart';
import 'config/game_balance.dart';
import 'core/audio_manager.dart';
import 'core/game_storage.dart';
import 'models/enemy_config.dart';
import 'models/player_stats.dart';
import 'models/save_data.dart';
import 'models/upgrade.dart';
import 'models/weapon_config.dart';

enum ArenaPhase { menu, countdown, playing, levelUp, paused, gameOver, victory }

class ArenaRunStats {
  int kills = 0;
  int level = 1;
  int xp = 0;
  double elapsed = 0;
  int chaptersCompletedThisRun = 0;
  int startingCompletedChapters = 0;
}

class ArenaSurvivalGame extends FlameGame with HasCollisionDetection {
  ArenaSurvivalGame({
    ArenaGameStorage? storage,
    this.onChapterComplete,
    this.onRunEnded,
  }) : storage = storage ?? MemoryArenaGameStorage();

  final ArenaGameStorage storage;
  final void Function(int chapter, int points)? onChapterComplete;
  final void Function({
    required bool victory,
    required int points,
    required int coins,
    required ArenaRunStats stats,
  })? onRunEnded;

  final phaseNotifier = ValueNotifier<ArenaPhase>(ArenaPhase.menu);
  final hudTick = ValueNotifier<int>(0);
  final saveNotifier = ValueNotifier<ArenaSaveData>(const ArenaSaveData());
  final pendingUpgrades = ValueNotifier<List<RunUpgrade>>(const []);
  final audio = ArenaAudioManager();

  late PlayerComponent player;
  late PlayerStats stats;
  BossComponent? boss;
  Sprite? spriteBasic;
  Sprite? spriteFast;
  Sprite? spriteTank;
  Sprite? spriteBoss;
  Sprite? spriteBolt;
  Sprite? spriteFireball;
  Sprite? spritePlayer;
  Sprite? spritePalm;
  Sprite? spriteXpFlame;
  Sprite? spriteXpGem;
  Sprite? spriteXpStar;
  BossAoeWarning? _aoeWarning;

  final run = ArenaRunStats();
  ArenaSaveData save = const ArenaSaveData();

  double _spawnTimer = 0;
  double _hudAcc = 0;
  final Map<WeaponId, double> _cooldowns = {};
  int _lastChapter = 1;
  int _pendingLevels = 0;
  bool _bossSpawned = false;
  bool _ending = false;
  int lastCoins = 0;
  int lastPoints = 0;
  final math.Random _rng = math.Random();
  final List<EnemyComponent> _enemyBuffer = [];
  final Vector2 _tmp = Vector2.zero();

  ArenaPhase get phase => phaseNotifier.value;

  @override
  Color backgroundColor() => const Color(0xFF1B3D24);

  @override
  Future<void> onLoad() async {
    save = await storage.load();
    saveNotifier.value = save;
    audio.musicVolume = save.musicVolume;
    audio.sfxVolume = save.sfxVolume;

    images.prefix = '';
    await images.loadAll(ArenaAssets.pngs);
    spriteBasic = Sprite(images.fromCache(ArenaAssets.zombieBasic));
    spriteFast = Sprite(images.fromCache(ArenaAssets.zombieFast));
    spriteTank = Sprite(images.fromCache(ArenaAssets.zombieTank));
    spriteBoss = Sprite(images.fromCache(ArenaAssets.zombieBoss));
    spriteBolt = Sprite(images.fromCache(ArenaAssets.lightning));
    spriteFireball = Sprite(images.fromCache(ArenaAssets.fireball));
    spritePlayer = Sprite(images.fromCache(ArenaAssets.lightning));
    spritePalm = await _spriteFromSvg(ArenaAssets.palmTree, 64);
    spriteXpFlame = await _spriteFromSvg(ArenaAssets.xpFlame, 48);
    spriteXpGem = await _spriteFromSvg(ArenaAssets.xpGem, 48);
    spriteXpStar = await _spriteFromSvg(ArenaAssets.xpStar, 48);

    stats = PlayerStats.fresh(save);
    player = PlayerComponent(stats: stats, sprite: spritePlayer);

    world.addAll([
      ArenaComponent(palmSprite: spritePalm),
      player,
    ]);

    camera.viewfinder.anchor = Anchor.center;
    camera.follow(player, snap: true);
    camera.setBounds(
      Rectangle.fromLTWH(0, 0, GameBalance.worldSize, GameBalance.worldSize),
      considerViewport: true,
    );

    pauseEngine();
  }

  Future<void> persist() async {
    await storage.save(save);
    saveNotifier.value = save;
  }

  void _notifyHud() {
    hudTick.value++;
  }

  Future<Sprite?> _spriteFromSvg(String asset, int px) async {
    try {
      final pictureInfo = await vg.loadPicture(SvgAssetLoader(asset), null);
      final image = await pictureInfo.picture.toImage(px, px);
      pictureInfo.picture.dispose();
      return Sprite(image);
    } catch (_) {
      return null;
    }
  }

  Sprite? _xpSpriteFor(EnemyType type) {
    switch (type) {
      case EnemyType.basic:
        return spriteXpGem;
      case EnemyType.fast:
        return spriteXpStar;
      case EnemyType.tank:
      case EnemyType.boss:
        return spriteXpFlame;
    }
  }

  Color _xpColorFor(EnemyType type) {
    switch (type) {
      case EnemyType.basic:
        return const Color(0xFF3FEBC0);
      case EnemyType.fast:
        return const Color(0xFFF0F038);
      case EnemyType.tank:
      case EnemyType.boss:
        return const Color(0xFFEB3F3F);
    }
  }

  Future<void> startRun({bool continueChapters = true}) async {
    save = await storage.load();
    final startChapter = continueChapters ? save.completedChapters : 0;
    _resetWorld(startChapter: startChapter);
    phaseNotifier.value = ArenaPhase.countdown;
    pendingUpgrades.value = const [];
    pauseEngine();
    _notifyHud();
  }

  void finishCountdown() {
    if (phase != ArenaPhase.countdown) return;
    phaseNotifier.value = ArenaPhase.playing;
    resumeEngine();
    _notifyHud();
  }

  void setMoveInput(double x, double y) {
    player.moveInput.setValues(x, y);
  }

  void clearMoveInput() {
    player.moveInput.setZero();
  }

  void pauseGame() {
    if (phase != ArenaPhase.playing) return;
    clearMoveInput();
    phaseNotifier.value = ArenaPhase.paused;
    pauseEngine();
    _notifyHud();
  }

  void resumeGame() {
    if (phase != ArenaPhase.paused) return;
    phaseNotifier.value = ArenaPhase.playing;
    resumeEngine();
    _notifyHud();
  }

  void returnToMenu() {
    clearMoveInput();
    pauseEngine();
    phaseNotifier.value = ArenaPhase.menu;
    _notifyHud();
  }

  void applyUpgrade(RunUpgrade upgrade) {
    upgrade.apply(stats);
    if (_pendingLevels > 0) _pendingLevels -= 1;
    pendingUpgrades.value = const [];
    if (_pendingLevels > 0) {
      _openLevelUp();
      _notifyHud();
      return;
    }
    phaseNotifier.value = ArenaPhase.playing;
    resumeEngine();
    _notifyHud();
  }

  Future<void> buyPermanentUpgrade(String id) async {
    save = await storage.load();
    var cost = 0;
    var next = save;
    switch (id) {
      case 'hp':
        if (save.permanentMaxHpLevel >= GameBalance.permanentUpgradeMaxLevel) {
          return;
        }
        cost = GameBalance.permanentUpgradeCost(save.permanentMaxHpLevel);
        if (save.coins < cost) return;
        next = save.copyWith(
          coins: save.coins - cost,
          permanentMaxHpLevel: save.permanentMaxHpLevel + 1,
        );
      case 'damage':
        if (save.permanentDamageLevel >= GameBalance.permanentUpgradeMaxLevel) {
          return;
        }
        cost = GameBalance.permanentUpgradeCost(save.permanentDamageLevel);
        if (save.coins < cost) return;
        next = save.copyWith(
          coins: save.coins - cost,
          permanentDamageLevel: save.permanentDamageLevel + 1,
        );
      case 'speed':
        if (save.permanentSpeedLevel >= GameBalance.permanentUpgradeMaxLevel) {
          return;
        }
        cost = GameBalance.permanentUpgradeCost(save.permanentSpeedLevel);
        if (save.coins < cost) return;
        next = save.copyWith(
          coins: save.coins - cost,
          permanentSpeedLevel: save.permanentSpeedLevel + 1,
        );
      case 'pickup':
        if (save.permanentPickupLevel >= GameBalance.permanentUpgradeMaxLevel) {
          return;
        }
        cost = GameBalance.permanentUpgradeCost(save.permanentPickupLevel);
        if (save.coins < cost) return;
        next = save.copyWith(
          coins: save.coins - cost,
          permanentPickupLevel: save.permanentPickupLevel + 1,
        );
      default:
        return;
    }
    save = next;
    await persist();
  }

  Future<void> updateVolumes({double? music, double? sfx}) async {
    save = save.copyWith(
      musicVolume: music ?? save.musicVolume,
      sfxVolume: sfx ?? save.sfxVolume,
    );
    audio.musicVolume = save.musicVolume;
    audio.sfxVolume = save.sfxVolume;
    await persist();
  }

  void _resetWorld({required int startChapter}) {
    world.children.whereType<EnemyComponent>().toList().forEach(
          (e) => e.removeFromParent(),
        );
    world.children.whereType<ProjectileComponent>().toList().forEach(
          (e) => e.removeFromParent(),
        );
    world.children.whereType<XpGemComponent>().toList().forEach(
          (e) => e.removeFromParent(),
        );
    world.children.whereType<BurstParticle>().toList().forEach(
          (e) => e.removeFromParent(),
        );
    world.children.whereType<ExplosionPulse>().toList().forEach(
          (e) => e.removeFromParent(),
        );
    world.children.whereType<RingPulse>().toList().forEach(
          (e) => e.removeFromParent(),
        );
    boss?.removeFromParent();
    _aoeWarning?.removeFromParent();
    boss = null;
    _aoeWarning = null;

    stats = PlayerStats.fresh(save);
    player.stats = stats;
    player.resetPosition();
    camera.follow(player, snap: true);

    run
      ..kills = 0
      ..level = 1
      ..xp = 0
      ..elapsed = GameBalance.startTimeForCompletedChapters(startChapter)
      ..chaptersCompletedThisRun = 0
      ..startingCompletedChapters = startChapter;

    _spawnTimer = 0;
    _hudAcc = 0;
    lastCoins = 0;
    lastPoints = 0;
    _cooldowns
      ..clear()
      ..[WeaponId.magicBolt] = 0
      ..[WeaponId.fireball] = 0
      ..[WeaponId.magicRing] = 0;
    _lastChapter = GameBalance.chapterForTime(run.elapsed);
    _pendingLevels = 0;
    _bossSpawned = run.elapsed >= GameBalance.gameDurationSeconds;
    _ending = false;
    if (_bossSpawned) {
      _spawnBoss();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (phase != ArenaPhase.playing || _ending) return;

    run.elapsed += dt;
    _handleChapters();
    _updateEnemies(dt);
    _updateGems(dt);
    _spawnEnemies(dt);
    _fireWeapons(dt);
    _updateBoss(dt);
    _cleanupOffworld();
    _hudAcc += dt;
    if (_hudAcc >= 0.1) {
      _hudAcc = 0;
      _notifyHud();
    }

    if (stats.hp <= 0) {
      _finish(victory: false);
    }
  }

  void _handleChapters() {
    final chapter = GameBalance.chapterForTime(run.elapsed);
    if (chapter > _lastChapter) {
      _lastChapter = chapter;
      final completed = chapter - 1;
      if (completed > run.startingCompletedChapters) {
        run.chaptersCompletedThisRun++;
        final persistChapter =
            math.max(save.completedChapters, completed).clamp(0, 6);
        save = save.copyWith(completedChapters: persistChapter);
        persist();
        onChapterComplete?.call(
          completed,
          GameBalance.pointsPerChapter,
        );
      }
    }
    if (!_bossSpawned && run.elapsed >= GameBalance.gameDurationSeconds) {
      _spawnBoss();
    }
  }

  void _spawnBoss() {
    _bossSpawned = true;
    world.children.whereType<EnemyComponent>().toList().forEach(
          (e) => e.removeFromParent(),
        );
    final pos = _spawnPointAroundPlayer();
    boss = BossComponent(position: pos, sprite: spriteBoss);
    world.add(boss!);
    audio.playSfx(ArenaSfx.bossSpawn);
    spawnBurst(world, pos, const Color(0xFFCE93D8), count: 14);
  }

  void _updateEnemies(double dt) {
    _enemyBuffer
      ..clear()
      ..addAll(world.children.whereType<EnemyComponent>());
    for (final enemy in _enemyBuffer) {
      if (enemy.dead) continue;
      enemy.chase(player, dt);
      if (player.invincibleFor <= 0 && enemy.touchesPlayer(player)) {
        player.takeDamage(enemy.damage, from: enemy.position);
        audio.playSfx(ArenaSfx.playerDamage);
        if (stats.hp <= 0) return;
      }
    }
  }

  void _updateGems(double dt) {
    final gems = world.children.whereType<XpGemComponent>().toList();
    for (final gem in gems) {
      gem.pullToward(player, dt);
      if (gem.readyToCollect ||
          (gem.position - player.position).length2 < 20 * 20) {
        _collectXp(gem.xp);
        audio.playSfx(ArenaSfx.xpPickup);
        spawnBurst(world, gem.position, gem.fallbackColor, count: 4);
        gem.removeFromParent();
      }
    }
  }

  void _collectXp(int amount) {
    run.xp += amount;
    var required = GameBalance.requiredXpForLevel(run.level);
    var leveled = false;
    while (run.xp >= required) {
      run.xp -= required;
      run.level += 1;
      _pendingLevels += 1;
      leveled = true;
      required = GameBalance.requiredXpForLevel(run.level);
    }
    if (leveled) {
      audio.playSfx(ArenaSfx.levelUp);
      spawnBurst(
        world,
        player.position.clone(),
        const Color(0xFFFFF59D),
        count: 10,
      );
      _openLevelUp();
    }
  }

  void _openLevelUp() {
    if (_pendingLevels <= 0) return;
    final pool = allRunUpgrades.where((u) => u.isAvailable(stats)).toList()
      ..shuffle(_rng);
    if (pool.isEmpty) {
      _pendingLevels = 0;
      return;
    }
    pendingUpgrades.value = pool.take(3).toList();
    clearMoveInput();
    phaseNotifier.value = ArenaPhase.levelUp;
    pauseEngine();
  }

  void _spawnEnemies(double dt) {
    if (_bossSpawned) return;
    final wave = GameBalance.waveForTime(run.elapsed);
    final alive = world.children.whereType<EnemyComponent>().length;
    if (alive >= wave.maxEnemies) return;
    _spawnTimer += dt;
    if (_spawnTimer < wave.interval) return;
    _spawnTimer = 0;
    final type = _pickEnemyType(wave);
    final config = switch (type) {
      EnemyType.fast => GameBalance.fastEnemy,
      EnemyType.tank => GameBalance.tankEnemy,
      _ => GameBalance.basicEnemy,
    };
    world.add(
      EnemyComponent(
        config: config,
        hpMultiplier: wave.hpMultiplier,
        damageMultiplier: wave.damageMultiplier,
        speedMultiplier: wave.speedMultiplier,
        position: _spawnPointAroundPlayer(),
        sprite: switch (type) {
          EnemyType.fast => spriteFast,
          EnemyType.tank => spriteTank,
          _ => spriteBasic,
        },
      ),
    );
  }

  EnemyType _pickEnemyType(SpawnWave wave) {
    final total = wave.basicWeight + wave.fastWeight + wave.tankWeight;
    if (total <= 0) return EnemyType.basic;
    var roll = _rng.nextInt(total);
    if (roll < wave.basicWeight) return EnemyType.basic;
    roll -= wave.basicWeight;
    if (roll < wave.fastWeight) return EnemyType.fast;
    return EnemyType.tank;
  }

  Vector2 _spawnPointAroundPlayer() {
    for (var i = 0; i < 12; i++) {
      final angle = _rng.nextDouble() * math.pi * 2;
      final dist = GameBalance.spawnMinDistance +
          _rng.nextDouble() *
              (GameBalance.spawnMaxDistance - GameBalance.spawnMinDistance);
      final x = (player.position.x + math.cos(angle) * dist)
          .clamp(40.0, GameBalance.worldSize - 40);
      final y = (player.position.y + math.sin(angle) * dist)
          .clamp(40.0, GameBalance.worldSize - 40);
      final p = Vector2(x, y);
      if ((p - player.position).length >= GameBalance.spawnMinDistance * 0.7) {
        return p;
      }
    }
    return Vector2(80, 80);
  }

  void _fireWeapons(double dt) {
    for (final id in stats.weapons) {
      _cooldowns[id] = (_cooldowns[id] ?? 0) - dt;
    }
    final nearest = _nearestTarget();
    for (final id in stats.weapons) {
      final weapon = _configFor(id);
      final cd = weapon.cooldown / stats.attackSpeedMultiplier;
      if ((_cooldowns[id] ?? 0) > 0) continue;
      if (weapon.kind == WeaponKind.area) {
        _fireRing(weapon);
        _cooldowns[id] = cd;
        continue;
      }
      if (nearest == null) continue;
      final dist = (nearest.position - player.position).length;
      if (dist > weapon.range) continue;
      _fireProjectiles(weapon, nearest);
      _cooldowns[id] = cd;
    }
  }

  WeaponConfig _configFor(WeaponId id) {
    switch (id) {
      case WeaponId.fireball:
        return GameBalance.fireball;
      case WeaponId.magicRing:
        return GameBalance.magicRing;
      case WeaponId.magicBolt:
        return GameBalance.magicBolt;
    }
  }

  PositionComponent? _nearestTarget() {
    PositionComponent? best;
    var bestDist = double.infinity;
    for (final enemy in world.children.whereType<EnemyComponent>()) {
      if (enemy.dead) continue;
      final d = (enemy.position - player.position).length2;
      if (d < bestDist) {
        bestDist = d;
        best = enemy;
      }
    }
    if (boss != null && !boss!.dead) {
      final d = (boss!.position - player.position).length2;
      if (d < bestDist) {
        best = boss;
      }
    }
    return best;
  }

  void _fireProjectiles(WeaponConfig weapon, PositionComponent target) {
    final count = weapon.kind == WeaponKind.projectile
        ? stats.projectileCount
        : 1;
    _tmp
      ..setFrom(target.position)
      ..sub(player.position);
    if (_tmp.length2 < 0.01) return;
    final baseAngle = math.atan2(_tmp.y, _tmp.x);
    final spread = count == 1 ? 0.0 : 0.18;
    final start = baseAngle - spread * (count - 1) / 2;
    for (var i = 0; i < count; i++) {
      final angle = start + spread * i;
      final dir = Vector2(math.cos(angle), math.sin(angle));
      world.add(
        ProjectileComponent(
          position: player.position.clone(),
          direction: dir,
          weapon: weapon,
          damage: _rollDamage(weapon.damage),
          onHit: _onProjectileHit,
          sprite: weapon.id == WeaponId.fireball ? spriteFireball : spriteBolt,
        ),
      );
    }
  }

  void _fireRing(WeaponConfig weapon) {
    world.add(
      RingPulse(
        position: player.position.clone(),
        maxRadius: weapon.range,
      ),
    );
    final dmg = _rollDamage(weapon.damage);
    final r2 = weapon.range * weapon.range;
    for (final enemy in world.children.whereType<EnemyComponent>().toList()) {
      if ((enemy.position - player.position).length2 <= r2) {
        _damageEnemy(enemy, dmg, explode: false);
      }
    }
    if (boss != null &&
        !boss!.dead &&
        (boss!.position - player.position).length2 <= r2) {
      _damageBoss(dmg);
    }
  }

  double _rollDamage(double base) {
    var dmg = base * stats.damageMultiplier;
    if (_rng.nextDouble() < stats.critChance) {
      dmg *= 2;
    }
    return dmg;
  }

  void _onProjectileHit(
    ProjectileComponent projectile,
    PositionComponent target,
  ) {
    if (target is BossComponent) {
      _damageBoss(projectile.damage);
      if (projectile.weapon.explodes) {
        _explode(
          projectile.position,
          projectile.weapon.explosionRadius,
          projectile.damage * 0.5,
        );
      }
      return;
    }
    if (target is! EnemyComponent) return;
    _damageEnemy(
      target,
      projectile.damage,
      explode: projectile.weapon.explodes,
    );
    if (projectile.weapon.explodes) {
      _explode(
        projectile.position,
        projectile.weapon.explosionRadius,
        projectile.damage * 0.45,
      );
    }
  }

  void _explode(Vector2 at, double radius, double damage) {
    world.add(ExplosionPulse(position: at.clone(), maxRadius: radius));
    final r2 = radius * radius;
    for (final enemy in world.children.whereType<EnemyComponent>().toList()) {
      if ((enemy.position - at).length2 <= r2) {
        _damageEnemy(enemy, damage, explode: false);
      }
    }
    if (boss != null &&
        !boss!.dead &&
        (boss!.position - at).length2 <= r2) {
      _damageBoss(damage);
    }
  }

  void _damageEnemy(EnemyComponent enemy, double damage, {required bool explode}) {
    if (enemy.dead) return;
    enemy.applyDamage(damage);
    audio.playSfx(ArenaSfx.enemyHit);
    if (enemy.dead) {
      audio.playSfx(ArenaSfx.enemyDeath);
      run.kills += 1;
      world.add(
        XpGemComponent(
          position: enemy.position.clone(),
          xp: enemy.xp,
          sprite: _xpSpriteFor(enemy.config.type),
          fallbackColor: _xpColorFor(enemy.config.type),
        ),
      );
      spawnBurst(
        world,
        enemy.position,
        _xpColorFor(enemy.config.type),
      );
      enemy.removeFromParent();
    }
  }

  void _damageBoss(double damage) {
    final current = boss;
    if (current == null || current.dead) return;
    current.applyDamage(damage);
    audio.playSfx(ArenaSfx.bossHit);
    if (current.dead) {
      spawnBurst(world, current.position, const Color(0xFFE1BEE7), count: 16);
      current.removeFromParent();
      boss = null;
      _finish(victory: true);
    }
  }

  void _updateBoss(double dt) {
    final current = boss;
    if (current == null || current.dead) return;
    final aoeHit = current.updateBoss(player, dt);
    if (current.isWarning && _aoeWarning == null && current.warningCenter != null) {
      _aoeWarning = BossAoeWarning(position: current.warningCenter!.clone());
      world.add(_aoeWarning!);
    }
    if (!current.isWarning && _aoeWarning != null) {
      _aoeWarning!.removeFromParent();
      _aoeWarning = null;
    }
    if (aoeHit && player.invincibleFor <= 0) {
      player.takeDamage(GameBalance.bossAoEDamage, from: current.position);
      audio.playSfx(ArenaSfx.playerDamage);
    }
    if (player.invincibleFor <= 0 && current.touchesPlayer(player)) {
      player.takeDamage(GameBalance.bossDamage, from: current.position);
      audio.playSfx(ArenaSfx.playerDamage);
    }
  }

  void _cleanupOffworld() {
    for (final p in world.children.whereType<ProjectileComponent>().toList()) {
      if (p.x < -40 ||
          p.y < -40 ||
          p.x > GameBalance.worldSize + 40 ||
          p.y > GameBalance.worldSize + 40) {
        p.removeFromParent();
      }
    }
  }

  Future<void> _finish({required bool victory}) async {
    if (_ending) return;
    _ending = true;
    clearMoveInput();
    pauseEngine();
    audio.playSfx(victory ? ArenaSfx.victory : ArenaSfx.gameOver);

    final coins = GameBalance.coinsForRun(
      kills: run.kills,
      survivalSeconds: run.elapsed,
      victory: victory,
    );
    final chapterPoints =
        run.chaptersCompletedThisRun * GameBalance.pointsPerChapter;
    lastCoins = coins;
    lastPoints = chapterPoints;
    var completed = save.completedChapters;
    if (victory) {
      completed = 0;
    }
    save = save.copyWith(
      coins: save.coins + coins,
      bestSurvivalSeconds: math.max(save.bestSurvivalSeconds, run.elapsed),
      highestLevel: math.max(save.highestLevel, run.level),
      totalKills: save.totalKills + run.kills,
      completedChapters: completed,
    );
    await persist();
    phaseNotifier.value = victory ? ArenaPhase.victory : ArenaPhase.gameOver;
    onRunEnded?.call(
      victory: victory,
      points: chapterPoints,
      coins: coins,
      stats: run,
    );
    _notifyHud();
  }
}
