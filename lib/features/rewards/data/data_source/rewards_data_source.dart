import '../../../../config/api_path.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../models/reward_model.dart';

abstract class RewardsDataSource {
  Future<List<RewardModel>> getRewards();
}

class RewardsDataSourceImpl extends RewardsDataSource {
  RewardsDataSourceImpl({required this.apiService});

  final ApiService apiService;

  @override
  Future<List<RewardModel>> getRewards() async {
    final res = await apiService.get(
      url: ApiPath.rewardsList,
      returnDataOnly: true,
    );
    if (res is List) {
      return res
          .whereType<Map>()
          .map((e) => RewardModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }
}
