import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../entities/conversation_entity.dart';
import '../repo/conversations_repo.dart';

class StartConversationUseCase
    extends UseCaseParam<ConversationEntity, int> {
  StartConversationUseCase({required this.conversationsRepo});

  final ConversationsRepo conversationsRepo;

  @override
  Future<Either<Failure, ConversationEntity>> call(int param) {
    return conversationsRepo.startConversation(param);
  }
}
