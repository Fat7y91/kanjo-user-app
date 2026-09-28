import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/models/paginated_response.dart';
import '../entities/conversation_entity.dart';
import '../entities/conversation_message_entity.dart';
import '../../data/models/conversations_list_model.dart';
import '../../data/models/send_conversation_message_model.dart';

abstract class ConversationsRepo {
  Future<Either<Failure, ConversationEntity>> startConversation(int vendorId);

  Future<Either<Failure, ConversationsListModel>> getConversations({
    int page = 1,
    int perPage = 50,
  });

  Future<Either<Failure, PaginatedResponse<ConversationMessageEntity>>>
      getMessages({
    required int conversationId,
    int page = 1,
    int perPage = 50,
  });

  Future<Either<Failure, SendConversationMessageModel>> sendMessage({
    required int conversationId,
    required String body,
    File? imageFile,
  });

  Future<Either<Failure, Unit>> acceptQuote({
    required int conversationId,
    required int quoteMessageId,
  });
}
