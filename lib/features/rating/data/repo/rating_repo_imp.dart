import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/rating_params_entity.dart';
import '../../domain/repo/rating_repo.dart';
import '../data_source/rating_data_source.dart';

class RatingRepoImp extends RatingRepo {
  RatingRepoImp({required this.dataSource});

  final RatingDataSource dataSource;

  @override
  Future<Either<Failure, bool>> rateVendor(RatingParamsEntity params) {
    return _guard(() => dataSource.rateVendor(params));
  }

  @override
  Future<Either<Failure, bool>> rateDeliveryPartner(RatingParamsEntity params) {
    return _guard(() => dataSource.rateDeliveryPartner(params));
  }

  Future<Either<Failure, bool>> _guard(Future<bool> Function() action) async {
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
