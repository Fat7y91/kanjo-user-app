import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/earn_rewards_params_entity.dart';
import '../repo/games_repo.dart';

class EarnRewardsUseCase
    extends UseCaseParam<bool, EarnRewardsParamsEntity> {
  EarnRewardsUseCase({required this.gamesRepo});

  final GamesRepo gamesRepo;

  @override
  Future<Either<Failure, bool>> call(EarnRewardsParamsEntity param) {
    return gamesRepo.earnRewards(param);
  }
}
