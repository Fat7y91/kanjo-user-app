import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../../../../../models/user_model.dart';
import '../repositories/auth_repo.dart';

class RegisterUserUseCase extends UseCaseParam<UserAuthResponseModel, Map<String, dynamic>> {
  final AuthRepo authRepo;

  RegisterUserUseCase(this.authRepo);

  @override
  Future<Either<Failure, UserAuthResponseModel>> call(
      Map<String, dynamic> param) {
    return authRepo.register(param);
  }
}

class VendorRegisterUserUseCase extends UseCaseParam<UserAuthResponseModel, Map<String, dynamic>> {
  final AuthRepo authRepo;

  VendorRegisterUserUseCase(this.authRepo);

  @override
  Future<Either<Failure, UserAuthResponseModel>> call(
      Map<String, dynamic> param) {
    return authRepo.vendorRegister(param);
  }
}