import '../config/game_balance.dart';
import 'save_data.dart';
import 'weapon_config.dart';

class PlayerStats {
  PlayerStats({
    required this.maxHp,
    required this.hp,
    required this.moveSpeed,
    required this.damageMultiplier,
    required this.attackSpeedMultiplier,
    required this.pickupRadius,
    required this.projectileCount,
    required this.critChance,
    required this.regenPer2Sec,
    required this.weapons,
  });

  double maxHp;
  double hp;
  double moveSpeed;
  double damageMultiplier;
  double attackSpeedMultiplier;
  double pickupRadius;
  int projectileCount;
  double critChance;
  double regenPer2Sec;
  Set<WeaponId> weapons;

  factory PlayerStats.fresh(ArenaSaveData save) {
    final maxHp = GameBalance.playerMaxHp +
        save.permanentMaxHpLevel * GameBalance.permanentMaxHpPerLevel;
    return PlayerStats(
      maxHp: maxHp,
      hp: maxHp,
      moveSpeed: GameBalance.playerSpeed *
          (1 + save.permanentSpeedLevel * GameBalance.permanentSpeedPerLevel),
      damageMultiplier:
          1 + save.permanentDamageLevel * GameBalance.permanentDamagePerLevel,
      attackSpeedMultiplier: 1,
      pickupRadius: GameBalance.playerPickupRadius *
          (1 +
              save.permanentPickupLevel * GameBalance.permanentPickupPerLevel),
      projectileCount: 1,
      critChance: 0,
      regenPer2Sec: 0,
      weapons: {WeaponId.magicBolt},
    );
  }

  void heal(double amount) {
    hp = (hp + amount).clamp(0, maxHp);
  }
}
