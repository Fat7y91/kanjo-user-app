import '../../domain/entities/daily_games_entity.dart';

class RewardsBalanceModel {
  const RewardsBalanceModel({
    required this.pointsBalance,
    required this.totalEarned,
    required this.totalRedeemed,
    required this.dailyGames,
    this.expireAt,
  });

  final int pointsBalance;
  final int totalEarned;
  final int totalRedeemed;
  final DailyGamesEntity dailyGames;
  final String? expireAt;

  factory RewardsBalanceModel.fromJson(Map<String, dynamic> json) {
    return RewardsBalanceModel(
      pointsBalance: _intFrom(
        json['points_balance'] ?? json['points'],
      ),
      totalEarned: _intFrom(json['total_earned']),
      totalRedeemed: _intFrom(json['total_redeemed']),
      expireAt: json['expire_at']?.toString(),
      dailyGames: DailyGamesEntity.fromJson(
        json['daily_games'] is Map
            ? Map<String, dynamic>.from(json['daily_games'] as Map)
            : const <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'points_balance': pointsBalance,
        'points': pointsBalance,
        'expire_at': expireAt,
        'daily_games': dailyGames.toJson(),
        'total_earned': totalEarned,
        'total_redeemed': totalRedeemed,
      };
}

int _intFrom(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
