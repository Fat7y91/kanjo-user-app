import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../models/user_model.dart';
import '../../domain/repositories/auth_repo.dart';
import '../data_sources/auth_data_source.dart';

class AuthRepoImpl extends AuthRepo {
  final AuthDataSource dataSource;

  AuthRepoImpl(this.dataSource);

  @override
  Future<Either<Failure, UserAuthResponseModel>> login(
      Map<String, dynamic> data) async {
    try {
      final res = await dataSource.login(data);
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
  Future<Either<Failure, UserAuthResponseModel>> register(
      Map<String, dynamic> data) async {
    try {
      final res = await dataSource.register(data);
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
  Future<Either<Failure, UserAuthResponseModel>> vendorRegister(
      Map<String, dynamic> data) async {
    try {
      final res = await dataSource.vendorRegister(data);
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
  Future<Either<Failure, UserAuthResponseModel>> selectRole(String role) async {
    try {
      final res = await dataSource.selectRole(role);
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
  Future<Either<Failure, UserModel>> getMyProfile() async {
    try {
      final res = await dataSource.getMyProfile();
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        final pending = pendingVerificationFromResponse(e.response?.data);
        if (pending != null && pending.isNotEmpty) {
          final data = e.response?.data;
          return Left(
            PendingVerificationFailure(
              pendingVerification: pending,
              message: data is Map ? data['message']?.toString() : null,
            ),
          );
        }
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, PreLoginResponseModel>> sendOtp(
      Map<String, dynamic> data) async {
    try {
      final res = await dataSource.sendOtp(data);
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
  Future<Either<Failure, PreLoginResponseModel>> preLogin(
      Map<String, dynamic> data) {
    return sendOtp(data);
  }

  @override
  Future<Either<Failure, UserAuthResponseModel>> verifyOtp(
      Map<String, dynamic> data) async {
    try {
      final res = await dataSource.verifyOtp(data);
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
  Future<Either<Failure, PreLoginResponseModel>> sendEmailVerification() async {
    try {
      return Right(await dataSource.sendEmailVerification());
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, PreLoginResponseModel>> sendPhoneVerification() async {
    try {
      return Right(await dataSource.sendPhoneVerification());
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, UserAuthResponseModel>> verifyEmailCode(
      String code) async {
    try {
      return Right(await dataSource.verifyEmailCode(code));
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, UserAuthResponseModel>> verifyPhoneCode(
      String code) async {
    try {
      return Right(await dataSource.verifyPhoneCode(code));
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, bool>> logOut() async {
    try {
      final res = await dataSource.logOut();
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
  Future<Either<Failure, bool>> deleteAccount() async {
    try {
      final res = await dataSource.deleteAccount();
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
  Future<Either<Failure, PreLoginResponseModel>> forgotPassword(
      String phone) async {
    try {
      return Right(await dataSource.forgotPassword(phone));
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, PreLoginResponseModel>> resetPassword({
    required String phone,
    required String otpCode,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      return Right(await dataSource.resetPassword(
        phone: phone,
        otpCode: otpCode,
        password: password,
        passwordConfirmation: passwordConfirmation,
      ));
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, UserAuthResponseModel>> socialLogin(
      String idToken) async {
    try {
      final res = await dataSource.socialLogin(idToken);
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
