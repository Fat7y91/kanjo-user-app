import 'package:fpdart/fpdart.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../../../../../models/user_model.dart';
import '../repositories/auth_repo.dart';

class SelectRoleUseCase extends UseCaseParam<UserAuthResponseModel, String> {
  final AuthRepo authRepo;

  SelectRoleUseCase(this.authRepo);

  @override
  Future<Either<Failure, UserAuthResponseModel>> call(String role) {
    return authRepo.selectRole(role);
  }
}
