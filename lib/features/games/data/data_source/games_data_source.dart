import 'package:dio/dio.dart';
import '../../../../config/api_path.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../../domain/entities/earn_rewards_params_entity.dart';
import '../../domain/entities/reward_transaction_entity.dart';
import '../models/game_config_model.dart';
import '../models/rewards_balance_model.dart';

abstract class GamesDataSource {
  Future<GameConfigModel> getGameConfig();

  Future<RewardsBalanceModel> getRewardsBalance();

  Future<bool> earnRewards(EarnRewardsParamsEntity params);

  Future<PaginatedResponse<RewardTransactionEntity>> getRewardsTransactions({
    int page = 1,
    int perPage = PaginationConfig.perPage,
  });
}

class GamesDataSourceImpl extends GamesDataSource {
  GamesDataSourceImpl({required this.apiService});

  final ApiService apiService;

  @override
  Future<GameConfigModel> getGameConfig() async {
    final res = await apiService.get(
      url: ApiPath.rewardsGameConfig,
      returnDataOnly: true,
    );
    if (res is Map) {
      return GameConfigModel.fromJson(Map<String, dynamic>.from(res));
    }
    return GameConfigModel.fromJson(const <String, dynamic>{});
  }

  @override
  Future<RewardsBalanceModel> getRewardsBalance() async {
    final res = await apiService.get(
      url: ApiPath.rewardsBalance,
      returnDataOnly: true,
    );
    if (res is Map) {
      return RewardsBalanceModel.fromJson(Map<String, dynamic>.from(res));
    }
    return RewardsBalanceModel.fromJson(const <String, dynamic>{});
  }

  @override
  Future<bool> earnRewards(EarnRewardsParamsEntity params) async {
    await apiService.post(
      url: ApiPath.rewardsEarn,
      requestBody: FormData.fromMap({
        'game_id': params.gameId.toString(),
        'points': params.points.toString(),
      }),
      returnDataOnly: true,
    );
    return true;
  }

  @override
  Future<PaginatedResponse<RewardTransactionEntity>> getRewardsTransactions({
    int page = 1,
    int perPage = PaginationConfig.perPage,
  }) async {
    final res = await apiService.get(
      url: ApiPath.rewardsTransactions,
      returnDataOnly: true,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );
    return parsePaginatedResponse(
      res,
      RewardTransactionEntity.fromJson,
    );
  }
}
