import 'package:fpdart/fpdart.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../models/user_model.dart';

abstract class AuthRepo {
  Future<Either<Failure, UserAuthResponseModel>> login(
      Map<String, dynamic> data);

  Future<Either<Failure, UserAuthResponseModel>> socialLogin(String idToken);

  Future<Either<Failure, bool>> logOut();

  Future<Either<Failure, bool>> deleteAccount();

  Future<Either<Failure, UserAuthResponseModel>> register(
      Map<String, dynamic> data);

  Future<Either<Failure, UserAuthResponseModel>> vendorRegister(
      Map<String, dynamic> data);

  Future<Either<Failure, UserAuthResponseModel>> selectRole(String role);

  Future<Either<Failure, PreLoginResponseModel>> sendOtp(
      Map<String, dynamic> data);

  Future<Either<Failure, PreLoginResponseModel>> preLogin(
      Map<String, dynamic> data);

  Future<Either<Failure, UserAuthResponseModel>> verifyOtp(
      Map<String, dynamic> data);

  Future<Either<Failure, PreLoginResponseModel>> sendEmailVerification();

  Future<Either<Failure, PreLoginResponseModel>> sendPhoneVerification();

  Future<Either<Failure, UserAuthResponseModel>> verifyEmailCode(String code);

  Future<Either<Failure, UserAuthResponseModel>> verifyPhoneCode(String code);

  Future<Either<Failure, UserModel>> getMyProfile();

  Future<Either<Failure, PreLoginResponseModel>> forgotPassword(String phone);

  Future<Either<Failure, PreLoginResponseModel>> resetPassword({
    required String phone,
    required String otpCode,
    required String password,
    required String passwordConfirmation,
  });
}
