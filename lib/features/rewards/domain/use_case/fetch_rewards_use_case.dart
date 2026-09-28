import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/reward_model.dart';
import '../repo/rewards_repo.dart';

class FetchRewardsUseCase extends UseCaseNoParam<List<RewardModel>> {
  FetchRewardsUseCase({required this.rewardsRepo});

  final RewardsRepo rewardsRepo;

  @override
  Future<Either<Failure, List<RewardModel>>> call() {
    return rewardsRepo.getRewards();
  }
}
