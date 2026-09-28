import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../../core/errors/failure.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repo/policy_repo.dart';
import '../data_source/policy_data_source.dart';

class PrivacyPolicyRepoImp extends PrivacyPolicyRepo {
  final PrivacyPolicyDataSource privacyPolicyDataSource;

  PrivacyPolicyRepoImp({required this.privacyPolicyDataSource});

  @override
  Future<Either<Failure, Message>> getPolicy() async {
    try {
      final settings = await privacyPolicyDataSource.getPolicy();
      return Right(settings);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, Message>> getWhoAreWe() async {
    try {
      final settings = await privacyPolicyDataSource.getWhoAreWe();
      return Right(settings);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }
}
