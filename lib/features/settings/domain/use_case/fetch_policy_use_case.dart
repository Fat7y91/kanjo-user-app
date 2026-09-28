import 'package:fpdart/fpdart.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/message_entity.dart';
import '../repo/policy_repo.dart';

class FetchPolicyUseCase extends UseCaseNoParam<Message> {
  final PrivacyPolicyRepo policyRepo;

  FetchPolicyUseCase({required this.policyRepo});

  @override
  Future<Either<Failure, Message>> call([void param]) async {
    final res = await policyRepo.getPolicy();
    return res;
  }
}

class FetchWhoAreWeUseCase extends UseCaseNoParam<Message> {
  final PrivacyPolicyRepo policyRepo;

  FetchWhoAreWeUseCase({required this.policyRepo});

  @override
  Future<Either<Failure, Message>> call([void param]) async {
    final res = await policyRepo.getWhoAreWe();
    return res;
  }
}