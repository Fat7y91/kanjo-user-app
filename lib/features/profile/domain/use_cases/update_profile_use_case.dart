import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../repositories/update_profile_repo.dart';

class UpdateProfileUseCase extends UseCaseParam<String, Map<String, dynamic>> {
  final UpdateProfileRepo _profileRepository;

  UpdateProfileUseCase(this._profileRepository);

  @override
  Future<Either<Failure, String>> call(Map<String, dynamic> param) {
    return _profileRepository.updateProfile(param);
  }
}
