import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/reward_transaction_entity.dart';
import '../repo/games_repo.dart';

class FetchRewardsTransactionsUseCase
    extends UseCaseNoParam<List<RewardTransactionEntity>> {
  FetchRewardsTransactionsUseCase({required this.gamesRepo});

  final GamesRepo gamesRepo;

  @override
  Future<Either<Failure, List<RewardTransactionEntity>>> call() {
    return gamesRepo.getRewardsTransactions();
  }
}
