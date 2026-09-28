class DailyGamesEntity {
  const DailyGamesEntity({
    required this.played,
    required this.remaining,
    required this.limit,
  });

  final int played;
  final int remaining;
  final int limit;

  bool get canEarnPoints => remaining > 0;

  factory DailyGamesEntity.fromJson(Map<String, dynamic> json) {
    return DailyGamesEntity(
      played: _intFrom(json['played']),
      remaining: json.containsKey('remaining')
          ? _intFrom(json['remaining'])
          : 1,
      limit: _intFrom(json['limit']),
    );
  }

  Map<String, dynamic> toJson() => {
        'played': played,
        'remaining': remaining,
        'limit': limit,
      };
}

int _intFrom(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
