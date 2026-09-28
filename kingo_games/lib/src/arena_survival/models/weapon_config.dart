enum WeaponId { magicBolt, fireball, magicRing }

enum WeaponKind { projectile, area }

class WeaponConfig {
  const WeaponConfig({
    required this.id,
    required this.name,
    required this.damage,
    required this.projectileSpeed,
    required this.range,
    required this.cooldown,
    required this.projectileRadius,
    required this.kind,
    this.explodes = false,
    this.explosionRadius = 0,
  });

  final WeaponId id;
  final String name;
  final double damage;
  final double projectileSpeed;
  final double range;
  final double cooldown;
  final double projectileRadius;
  final WeaponKind kind;
  final bool explodes;
  final double explosionRadius;
}
