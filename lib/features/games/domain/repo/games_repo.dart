import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../data/models/game_config_model.dart';
import '../../data/models/rewards_balance_model.dart';
import '../entities/earn_rewards_params_entity.dart';
import '../entities/reward_transaction_entity.dart';

abstract class GamesRepo {
  Future<Either<Failure, GameConfigModel>> getGameConfig();

  Future<Either<Failure, RewardsBalanceModel>> getRewardsBalance();

  Future<Either<Failure, bool>> earnRewards(EarnRewardsParamsEntity params);

  Future<Either<Failure, List<RewardTransactionEntity>>>
      getRewardsTransactions();
}
