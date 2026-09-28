import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../../data/models/send_conversation_message_model.dart';
import '../repo/conversations_repo.dart';

class SendConversationMessageParams {
  const SendConversationMessageParams({
    required this.conversationId,
    required this.body,
    this.imageFile,
  });

  final int conversationId;
  final String body;
  final File? imageFile;
}

class SendConversationMessageUseCase extends UseCaseParam<
    SendConversationMessageModel, SendConversationMessageParams> {
  SendConversationMessageUseCase({required this.conversationsRepo});

  final ConversationsRepo conversationsRepo;

  @override
  Future<Either<Failure, SendConversationMessageModel>> call(
    SendConversationMessageParams param,
  ) {
    return conversationsRepo.sendMessage(
      conversationId: param.conversationId,
      body: param.body,
      imageFile: param.imageFile,
    );
  }
}
