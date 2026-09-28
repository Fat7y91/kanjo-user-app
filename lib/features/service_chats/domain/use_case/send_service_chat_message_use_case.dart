import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../../data/models/send_service_chat_message_model.dart';
import '../repo/service_chats_repo.dart';

class SendServiceChatMessageParams {
  const SendServiceChatMessageParams({
    required this.conversationId,
    required this.body,
    this.imageFile,
  });

  final int conversationId;
  final String body;
  final File? imageFile;
}

class SendServiceChatMessageUseCase extends UseCaseParam<
    SendServiceChatMessageModel, SendServiceChatMessageParams> {
  SendServiceChatMessageUseCase({required this.serviceChatsRepo});

  final ServiceChatsRepo serviceChatsRepo;

  @override
  Future<Either<Failure, SendServiceChatMessageModel>> call(
    SendServiceChatMessageParams param,
  ) {
    return serviceChatsRepo.sendMessage(
      conversationId: param.conversationId,
      body: param.body,
      imageFile: param.imageFile,
    );
  }
}
