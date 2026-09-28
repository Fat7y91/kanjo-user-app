import 'package:fpdart/fpdart.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../../../../../models/user_model.dart';
import '../repositories/auth_repo.dart';

class LoginUserUseCase
    extends UseCaseParam<UserAuthResponseModel, Map<String, dynamic>> {
  final AuthRepo authRepo;

  LoginUserUseCase(this.authRepo);

  @override
  Future<Either<Failure, UserAuthResponseModel>> call(
      Map<String, dynamic> param) {
    return authRepo.login(param);
  }
}

class LogOutUserUseCase extends UseCaseNoParam<bool> {
  final AuthRepo authRepo;

  LogOutUserUseCase(this.authRepo);

  @override
  Future<Either<Failure, bool>> call([void param]) {
    return authRepo.logOut();
  }
}

class DeleteAccountUseCase extends UseCaseNoParam<bool> {
  final AuthRepo authRepo;

  DeleteAccountUseCase(this.authRepo);

  @override
  Future<Either<Failure, bool>> call([void param]) {
    return authRepo.deleteAccount();
  }
}

class PreLoginUserUseCase
    extends UseCaseParam<PreLoginResponseModel, Map<String, dynamic>> {
  final AuthRepo authRepo;

  PreLoginUserUseCase(this.authRepo);

  @override
  Future<Either<Failure, PreLoginResponseModel>> call(
      Map<String, dynamic> param) {
    return authRepo.sendOtp(param);
  }
}

class SendOtpUseCase
    extends UseCaseParam<PreLoginResponseModel, Map<String, dynamic>> {
  final AuthRepo authRepo;

  SendOtpUseCase(this.authRepo);

  @override
  Future<Either<Failure, PreLoginResponseModel>> call(
      Map<String, dynamic> param) {
    return authRepo.sendOtp(param);
  }
}

class VerifyOtpUseCase
    extends UseCaseParam<UserAuthResponseModel, Map<String, dynamic>> {
  final AuthRepo authRepo;

  VerifyOtpUseCase(this.authRepo);

  @override
  Future<Either<Failure, UserAuthResponseModel>> call(
      Map<String, dynamic> param) {
    return authRepo.verifyOtp(param);
  }
}

class SendEmailVerificationUseCase
    extends UseCaseNoParam<PreLoginResponseModel> {
  final AuthRepo authRepo;

  SendEmailVerificationUseCase(this.authRepo);

  @override
  Future<Either<Failure, PreLoginResponseModel>> call() {
    return authRepo.sendEmailVerification();
  }
}

class SendPhoneVerificationUseCase
    extends UseCaseNoParam<PreLoginResponseModel> {
  final AuthRepo authRepo;

  SendPhoneVerificationUseCase(this.authRepo);

  @override
  Future<Either<Failure, PreLoginResponseModel>> call() {
    return authRepo.sendPhoneVerification();
  }
}

class VerifyEmailCodeUseCase
    extends UseCaseParam<UserAuthResponseModel, String> {
  final AuthRepo authRepo;

  VerifyEmailCodeUseCase(this.authRepo);

  @override
  Future<Either<Failure, UserAuthResponseModel>> call(String param) {
    return authRepo.verifyEmailCode(param);
  }
}

class VerifyPhoneCodeUseCase
    extends UseCaseParam<UserAuthResponseModel, String> {
  final AuthRepo authRepo;

  VerifyPhoneCodeUseCase(this.authRepo);

  @override
  Future<Either<Failure, UserAuthResponseModel>> call(String param) {
    return authRepo.verifyPhoneCode(param);
  }
}

class ForgotPasswordUseCase
    extends UseCaseParam<PreLoginResponseModel, String> {
  final AuthRepo authRepo;

  ForgotPasswordUseCase(this.authRepo);

  @override
  Future<Either<Failure, PreLoginResponseModel>> call(String param) {
    return authRepo.forgotPassword(param);
  }
}

class ResetPasswordUseCase
    extends UseCaseParam<PreLoginResponseModel, Map<String, dynamic>> {
  final AuthRepo authRepo;

  ResetPasswordUseCase(this.authRepo);

  @override
  Future<Either<Failure, PreLoginResponseModel>> call(
      Map<String, dynamic> param) {
    return authRepo.resetPassword(
      phone: param['phone'] as String,
      otpCode: param['otp_code'] as String,
      password: param['password'] as String,
      passwordConfirmation: param['password_confirmation'] as String,
    );
  }
}

class SocialLoginUserUseCase
    extends UseCaseParam<UserAuthResponseModel, String> {
  final AuthRepo authRepo;

  SocialLoginUserUseCase(this.authRepo);

  @override
  Future<Either<Failure, UserAuthResponseModel>> call(String param) {
    return authRepo.socialLogin(param);
  }
}
