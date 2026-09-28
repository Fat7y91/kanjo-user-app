import 'package:fpdart/fpdart.dart';
import 'package:heraj/features/settings/data/models/settings_model.dart';
import 'package:heraj/features/settings/domain/repo/settings_repo.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';

class FetchSettingsUseCase extends UseCaseNoParam<SettingsModel> {
  final SettingsRepo policyRepo;

  FetchSettingsUseCase({required this.policyRepo});

  @override
  Future<Either<Failure, SettingsModel>> call([void param]) async {
    final res = await policyRepo.getSettings();
    return res;
  }
}
