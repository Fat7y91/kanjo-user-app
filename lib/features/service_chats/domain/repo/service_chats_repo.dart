import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../data/models/send_service_chat_message_model.dart';
import '../../data/models/service_chat_messages_model.dart';
import '../../data/models/service_conversations_list_model.dart';
import '../entities/service_conversation_entity.dart';

abstract class ServiceChatsRepo {
  Future<Either<Failure, ServiceConversationEntity>> startConversation(
    int serviceProviderId,
  );

  Future<Either<Failure, ServiceConversationsListModel>> getConversations({
    int page = 1,
    int perPage = 20,
  });

  Future<Either<Failure, ServiceChatMessagesModel>> getMessages({
    required int conversationId,
    int page = 1,
    int perPage = 50,
  });

  Future<Either<Failure, SendServiceChatMessageModel>> sendMessage({
    required int conversationId,
    required String body,
    File? imageFile,
  });
}
