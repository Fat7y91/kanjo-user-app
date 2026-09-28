import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../domain/repositories/forget_password_repo.dart';
import '../data_sources/forget_password_data_source.dart';

class ForgetPasswordRepoImpl extends ForgetPasswordRepo {
  final ForgetDataSource dataSource;
  @override
  final String code;
  @override
  final String sendTo;

  ForgetPasswordRepoImpl(
      {required this.dataSource, required this.code, required this.sendTo});

  @override
  Future<Either<Failure, bool>> resetPassword(
      {required String password}) async {
    try {
      final res = await dataSource.resetPassword(
          code: code, password: password, email: sendTo);
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }
}
