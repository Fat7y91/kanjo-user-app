import 'game_config_model.dart';
import 'rewards_balance_model.dart';

class GameCenterModel {
  const GameCenterModel({
    required this.config,
    required this.balance,
  });

  final GameConfigModel config;
  final RewardsBalanceModel balance;

  Map<String, dynamic> toJson() => {
        'config': config.toJson(),
        'balance': balance.toJson(),
      };

  factory GameCenterModel.fromJson(Map<String, dynamic> json) {
    return GameCenterModel(
      config: GameConfigModel.fromJson(
        json['config'] is Map
            ? Map<String, dynamic>.from(json['config'] as Map)
            : const <String, dynamic>{},
      ),
      balance: RewardsBalanceModel.fromJson(
        json['balance'] is Map
            ? Map<String, dynamic>.from(json['balance'] as Map)
            : const <String, dynamic>{},
      ),
    );
  }
}
