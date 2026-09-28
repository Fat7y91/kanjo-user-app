import 'package:heraj/features/games/data/models/rewards_balance_model.dart';
import 'reward_model.dart';

class RewardsCenterModel {
  const RewardsCenterModel({
    required this.balance,
    required this.rewards,
  });

  final RewardsBalanceModel balance;
  final List<RewardModel> rewards;

  int get validRewardsCount {
    final points = balance.pointsBalance;
    return rewards.where((reward) => reward.isUsable(points)).length;
  }

  factory RewardsCenterModel.fromJson(Map<String, dynamic> json) {
    return RewardsCenterModel(
      balance: RewardsBalanceModel.fromJson(
        json['balance'] is Map
            ? Map<String, dynamic>.from(json['balance'] as Map)
            : const <String, dynamic>{},
      ),
      rewards: json['rewards'] is List
          ? (json['rewards'] as List)
              .whereType<Map>()
              .map((e) => RewardModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'balance': balance.toJson(),
        'rewards': rewards.map((e) => e.toJson()).toList(),
      };
}
