import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../../data/models/service_chat_messages_model.dart';
import '../repo/service_chats_repo.dart';

class FetchServiceChatMessagesParams {
  const FetchServiceChatMessagesParams({
    required this.conversationId,
    this.page = 1,
    this.perPage = 50,
  });

  final int conversationId;
  final int page;
  final int perPage;
}

class FetchServiceChatMessagesUseCase extends UseCaseParam<
    ServiceChatMessagesModel, FetchServiceChatMessagesParams> {
  FetchServiceChatMessagesUseCase({required this.serviceChatsRepo});

  final ServiceChatsRepo serviceChatsRepo;

  @override
  Future<Either<Failure, ServiceChatMessagesModel>> call(
    FetchServiceChatMessagesParams param,
  ) {
    return serviceChatsRepo.getMessages(
      conversationId: param.conversationId,
      page: param.page,
      perPage: param.perPage,
    );
  }
}
