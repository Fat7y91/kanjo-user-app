class GameConfigLimitsEntity {
  const GameConfigLimitsEntity({
    required this.maximumPointsPerGame,
    required this.maximumPointsPerUserPerDay,
    required this.maximumSuccessfulGamesPerUserPerDay,
  });

  final int maximumPointsPerGame;
  final int maximumPointsPerUserPerDay;
  final int maximumSuccessfulGamesPerUserPerDay;

  factory GameConfigLimitsEntity.fromJson(Map<String, dynamic> json) {
    return GameConfigLimitsEntity(
      maximumPointsPerGame: _intFrom(json['maximum_points_per_game']),
      maximumPointsPerUserPerDay:
          _intFrom(json['maximum_points_per_user_per_day']),
      maximumSuccessfulGamesPerUserPerDay:
          _intFrom(json['maximum_successful_games_per_user_per_day']),
    );
  }

  Map<String, dynamic> toJson() => {
        'maximum_points_per_game': maximumPointsPerGame,
        'maximum_points_per_user_per_day': maximumPointsPerUserPerDay,
        'maximum_successful_games_per_user_per_day':
            maximumSuccessfulGamesPerUserPerDay,
      };
}

int _intFrom(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
