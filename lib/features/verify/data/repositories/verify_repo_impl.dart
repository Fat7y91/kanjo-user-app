import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/get.dart';

import '../../../../../core/errors/failure.dart';
import '../../domain/repositories/verification_repo.dart';
import '../data_sources/verification_data_source.dart';

class VerifyRepoImpl extends VerificationRepo {
  final VerificationDataSource dataSource;
  @override
  final String sendTo;

  VerifyRepoImpl({required this.dataSource, required this.sendTo});

  @override
  Future<Either<Failure, bool>> verify(String code,{String? emailOrPhone}) async {
    try {
      final res = await dataSource.verify(code,emailOrPhone: emailOrPhone);
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> resend() async {
    try {
      final res = await dataSource.resend(emailOrPhone: sendTo);
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> send() async {
    try {
      final res = await dataSource.send(emailOrPhone: sendTo);
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  String get title =>
      sendTo.isEmail ? "Confirm Email Address" : "Confirm Phone Number";

  @override
  String get type => sendTo.isEmail ? "your email" : "your phone";
}
