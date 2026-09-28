class ArenaSaveData {
  const ArenaSaveData({
    this.coins = 0,
    this.bestSurvivalSeconds = 0,
    this.highestLevel = 1,
    this.totalKills = 0,
    this.permanentMaxHpLevel = 0,
    this.permanentDamageLevel = 0,
    this.permanentSpeedLevel = 0,
    this.permanentPickupLevel = 0,
    this.completedChapters = 0,
    this.musicVolume = 0.7,
    this.sfxVolume = 0.9,
  });

  final int coins;
  final double bestSurvivalSeconds;
  final int highestLevel;
  final int totalKills;
  final int permanentMaxHpLevel;
  final int permanentDamageLevel;
  final int permanentSpeedLevel;
  final int permanentPickupLevel;
  final int completedChapters;
  final double musicVolume;
  final double sfxVolume;

  ArenaSaveData copyWith({
    int? coins,
    double? bestSurvivalSeconds,
    int? highestLevel,
    int? totalKills,
    int? permanentMaxHpLevel,
    int? permanentDamageLevel,
    int? permanentSpeedLevel,
    int? permanentPickupLevel,
    int? completedChapters,
    double? musicVolume,
    double? sfxVolume,
  }) {
    return ArenaSaveData(
      coins: coins ?? this.coins,
      bestSurvivalSeconds: bestSurvivalSeconds ?? this.bestSurvivalSeconds,
      highestLevel: highestLevel ?? this.highestLevel,
      totalKills: totalKills ?? this.totalKills,
      permanentMaxHpLevel: permanentMaxHpLevel ?? this.permanentMaxHpLevel,
      permanentDamageLevel: permanentDamageLevel ?? this.permanentDamageLevel,
      permanentSpeedLevel: permanentSpeedLevel ?? this.permanentSpeedLevel,
      permanentPickupLevel: permanentPickupLevel ?? this.permanentPickupLevel,
      completedChapters: completedChapters ?? this.completedChapters,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
    );
  }

  factory ArenaSaveData.fromJson(Map<String, dynamic> json) {
    return ArenaSaveData(
      coins: json['coins'] is int
          ? json['coins'] as int
          : int.tryParse(json['coins']?.toString() ?? '') ?? 0,
      bestSurvivalSeconds: json['best_survival_seconds'] is num
          ? (json['best_survival_seconds'] as num).toDouble()
          : double.tryParse(json['best_survival_seconds']?.toString() ?? '') ??
              0,
      highestLevel: json['highest_level'] is int
          ? json['highest_level'] as int
          : int.tryParse(json['highest_level']?.toString() ?? '') ?? 1,
      totalKills: json['total_kills'] is int
          ? json['total_kills'] as int
          : int.tryParse(json['total_kills']?.toString() ?? '') ?? 0,
      permanentMaxHpLevel: json['perm_max_hp'] is int
          ? json['perm_max_hp'] as int
          : int.tryParse(json['perm_max_hp']?.toString() ?? '') ?? 0,
      permanentDamageLevel: json['perm_damage'] is int
          ? json['perm_damage'] as int
          : int.tryParse(json['perm_damage']?.toString() ?? '') ?? 0,
      permanentSpeedLevel: json['perm_speed'] is int
          ? json['perm_speed'] as int
          : int.tryParse(json['perm_speed']?.toString() ?? '') ?? 0,
      permanentPickupLevel: json['perm_pickup'] is int
          ? json['perm_pickup'] as int
          : int.tryParse(json['perm_pickup']?.toString() ?? '') ?? 0,
      completedChapters: json['completed_chapters'] is int
          ? json['completed_chapters'] as int
          : int.tryParse(json['completed_chapters']?.toString() ?? '') ?? 0,
      musicVolume: json['music_volume'] is num
          ? (json['music_volume'] as num).toDouble()
          : 0.7,
      sfxVolume: json['sfx_volume'] is num
          ? (json['sfx_volume'] as num).toDouble()
          : 0.9,
    );
  }

  Map<String, dynamic> toJson() => {
        'coins': coins,
        'best_survival_seconds': bestSurvivalSeconds,
        'highest_level': highestLevel,
        'total_kills': totalKills,
        'perm_max_hp': permanentMaxHpLevel,
        'perm_damage': permanentDamageLevel,
        'perm_speed': permanentSpeedLevel,
        'perm_pickup': permanentPickupLevel,
        'completed_chapters': completedChapters,
        'music_volume': musicVolume,
        'sfx_volume': sfxVolume,
      };
}
