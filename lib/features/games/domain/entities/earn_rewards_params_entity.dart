class GameRewardIds {
  static const flyingBird = 1;
  static const gunShooter = 2;
  static const arenaSurvival = 3;
}

class EarnRewardsParamsEntity {
  const EarnRewardsParamsEntity({
    required this.gameId,
    required this.points,
  });

  final int gameId;
  final int points;

  factory EarnRewardsParamsEntity.fromJson(Map<String, dynamic> json) {
    return EarnRewardsParamsEntity(
      gameId: _intFrom(json['game_id']),
      points: _intFrom(json['points']),
    );
  }

  Map<String, dynamic> toJson() => {
        'game_id': gameId,
        'points': points,
      };
}

int _intFrom(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
