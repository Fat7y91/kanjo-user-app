import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../data/models/reward_model.dart';

abstract class RewardsRepo {
  Future<Either<Failure, List<RewardModel>>> getRewards();
}
