import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/rewards_balance_model.dart';
import '../repo/games_repo.dart';

class FetchRewardsBalanceUseCase extends UseCaseNoParam<RewardsBalanceModel> {
  FetchRewardsBalanceUseCase({required this.gamesRepo});

  final GamesRepo gamesRepo;

  @override
  Future<Either<Failure, RewardsBalanceModel>> call() {
    return gamesRepo.getRewardsBalance();
  }
}
