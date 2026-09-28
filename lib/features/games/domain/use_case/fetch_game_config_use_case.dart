import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/game_config_model.dart';
import '../repo/games_repo.dart';

class FetchGameConfigUseCase extends UseCaseNoParam<GameConfigModel> {
  FetchGameConfigUseCase({required this.gamesRepo});

  final GamesRepo gamesRepo;

  @override
  Future<Either<Failure, GameConfigModel>> call() {
    return gamesRepo.getGameConfig();
  }
}
