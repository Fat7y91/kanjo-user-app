import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repo/rewards_repo.dart';
import '../data_source/rewards_data_source.dart';
import '../models/reward_model.dart';

class RewardsRepoImp extends RewardsRepo {
  RewardsRepoImp({required this.dataSource});

  final RewardsDataSource dataSource;

  @override
  Future<Either<Failure, List<RewardModel>>> getRewards() async {
    try {
      return Right(await dataSource.getRewards());
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }
}
