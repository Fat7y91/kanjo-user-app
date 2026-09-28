import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/earn_rewards_params_entity.dart';
import '../../domain/entities/reward_transaction_entity.dart';
import '../../domain/repo/games_repo.dart';
import '../data_source/games_data_source.dart';
import '../models/game_config_model.dart';
import '../models/rewards_balance_model.dart';

class GamesRepoImp extends GamesRepo {
  GamesRepoImp({required this.dataSource});

  final GamesDataSource dataSource;

  @override
  Future<Either<Failure, GameConfigModel>> getGameConfig() {
    return _guard(dataSource.getGameConfig);
  }

  @override
  Future<Either<Failure, RewardsBalanceModel>> getRewardsBalance() {
    return _guard(dataSource.getRewardsBalance);
  }

  @override
  Future<Either<Failure, bool>> earnRewards(EarnRewardsParamsEntity params) {
    return _guard(() => dataSource.earnRewards(params));
  }

  @override
  Future<Either<Failure, List<RewardTransactionEntity>>>
      getRewardsTransactions() {
    return _guard(() {
      return fetchAllPaginatedPages(
        fetchPage: (page) => dataSource.getRewardsTransactions(page: page),
      );
    });
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }
}
