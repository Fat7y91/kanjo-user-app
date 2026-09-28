import '../config/arena_assets.dart';
import 'player_stats.dart';
import 'weapon_config.dart';

enum RunUpgradeId {
  damage,
  attackSpeed,
  moveSpeed,
  maxHp,
  pickupRadius,
  projectileCount,
  critChance,
  regen,
  unlockFireball,
  unlockMagicRing,
}

class RunUpgrade {
  const RunUpgrade({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.asset,
  });

  final RunUpgradeId id;
  final String title;
  final String description;
  final String icon;
  final String? asset;

  bool isAvailable(PlayerStats stats) {
    switch (id) {
      case RunUpgradeId.projectileCount:
        return stats.projectileCount < 5;
      case RunUpgradeId.unlockFireball:
        return !stats.weapons.contains(WeaponId.fireball);
      case RunUpgradeId.unlockMagicRing:
        return !stats.weapons.contains(WeaponId.magicRing);
      default:
        return true;
    }
  }

  void apply(PlayerStats stats) {
    switch (id) {
      case RunUpgradeId.damage:
        stats.damageMultiplier *= 1.15;
      case RunUpgradeId.attackSpeed:
        stats.attackSpeedMultiplier *= 1.10;
      case RunUpgradeId.moveSpeed:
        stats.moveSpeed *= 1.10;
      case RunUpgradeId.maxHp:
        stats.maxHp += 20;
        stats.heal(20);
      case RunUpgradeId.pickupRadius:
        stats.pickupRadius *= 1.25;
      case RunUpgradeId.projectileCount:
        stats.projectileCount += 1;
      case RunUpgradeId.critChance:
        stats.critChance = (stats.critChance + 0.10).clamp(0, 0.8);
      case RunUpgradeId.regen:
        stats.regenPer2Sec += 1;
      case RunUpgradeId.unlockFireball:
        stats.weapons.add(WeaponId.fireball);
      case RunUpgradeId.unlockMagicRing:
        stats.weapons.add(WeaponId.magicRing);
    }
  }
}

const allRunUpgrades = <RunUpgrade>[
  RunUpgrade(
    id: RunUpgradeId.damage,
    title: 'Damage',
    description: '+15% weapon damage',
    icon: '⚔️',
  ),
  RunUpgrade(
    id: RunUpgradeId.attackSpeed,
    title: 'Attack Speed',
    description: '+10% attack speed',
    icon: '⚡',
    asset: ArenaAssets.lightning,
  ),
  RunUpgrade(
    id: RunUpgradeId.moveSpeed,
    title: 'Movement',
    description: '+10% move speed',
    icon: '👟',
  ),
  RunUpgrade(
    id: RunUpgradeId.maxHp,
    title: 'Max HP',
    description: '+20 HP and heal',
    icon: '❤️',
    asset: ArenaAssets.heart,
  ),
  RunUpgrade(
    id: RunUpgradeId.pickupRadius,
    title: 'Magnet',
    description: '+25% XP pickup radius',
    icon: '🧲',
  ),
  RunUpgrade(
    id: RunUpgradeId.projectileCount,
    title: 'Multi Shot',
    description: '+1 projectile',
    icon: '✨',
    asset: ArenaAssets.bullet,
  ),
  RunUpgrade(
    id: RunUpgradeId.critChance,
    title: 'Critical',
    description: '+10% crit chance (2x)',
    icon: '💥',
  ),
  RunUpgrade(
    id: RunUpgradeId.regen,
    title: 'Regen',
    description: '+1 HP every 2 seconds',
    icon: '🌿',
  ),
  RunUpgrade(
    id: RunUpgradeId.unlockFireball,
    title: 'Fireball',
    description: 'Unlock Fireball weapon',
    icon: '🔥',
    asset: ArenaAssets.fireball,
  ),
  RunUpgrade(
    id: RunUpgradeId.unlockMagicRing,
    title: 'Magic Ring',
    description: 'Unlock area attack',
    icon: '⭕',
  ),
];
