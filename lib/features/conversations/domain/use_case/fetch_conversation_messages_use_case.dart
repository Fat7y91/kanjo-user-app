import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/models/paginated_response.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../entities/conversation_message_entity.dart';
import '../repo/conversations_repo.dart';

class FetchConversationMessagesParams {
  const FetchConversationMessagesParams({
    required this.conversationId,
    this.page = 1,
    this.perPage = 50,
  });

  final int conversationId;
  final int page;
  final int perPage;
}

class FetchConversationMessagesUseCase extends UseCaseParam<
    PaginatedResponse<ConversationMessageEntity>,
    FetchConversationMessagesParams> {
  FetchConversationMessagesUseCase({required this.conversationsRepo});

  final ConversationsRepo conversationsRepo;

  @override
  Future<Either<Failure, PaginatedResponse<ConversationMessageEntity>>> call(
    FetchConversationMessagesParams param,
  ) {
    return conversationsRepo.getMessages(
      conversationId: param.conversationId,
      page: param.page,
      perPage: param.perPage,
    );
  }
}
