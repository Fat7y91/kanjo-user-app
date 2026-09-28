enum EnemyType { basic, fast, tank, boss }

class EnemyConfig {
  const EnemyConfig({
    required this.type,
    required this.maxHp,
    required this.speed,
    required this.damage,
    required this.xp,
    required this.radius,
  });

  final EnemyType type;
  final double maxHp;
  final double speed;
  final double damage;
  final int xp;
  final double radius;
}
