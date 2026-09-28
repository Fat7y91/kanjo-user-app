import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../entities/service_conversation_entity.dart';
import '../repo/service_chats_repo.dart';

class StartServiceConversationUseCase
    extends UseCaseParam<ServiceConversationEntity, int> {
  StartServiceConversationUseCase({required this.serviceChatsRepo});

  final ServiceChatsRepo serviceChatsRepo;

  @override
  Future<Either<Failure, ServiceConversationEntity>> call(int param) {
    return serviceChatsRepo.startConversation(param);
  }
}
