import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../domain/entities/service_conversation_entity.dart';
import '../../domain/repo/service_chats_repo.dart';
import '../data_source/service_chats_data_source.dart';
import '../models/send_service_chat_message_model.dart';
import '../models/service_chat_messages_model.dart';
import '../models/service_conversations_list_model.dart';

class ServiceChatsRepoImp extends ServiceChatsRepo {
  ServiceChatsRepoImp({required this.dataSource});

  final ServiceChatsDataSource dataSource;

  Either<Failure, T> _catch<T>(Object e) {
    if (e is DioException) {
      return Left(ServerFailure.fromDioError(e));
    }
    return Left(GeneralError(e));
  }

  @override
  Future<Either<Failure, ServiceConversationEntity>> startConversation(
    int serviceProviderId,
  ) async {
    try {
      return Right(await dataSource.startConversation(serviceProviderId));
    } catch (e) {
      return _catch(e);
    }
  }

  @override
  Future<Either<Failure, ServiceConversationsListModel>> getConversations({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      return Right(
        await dataSource.getConversations(page: page, perPage: perPage),
      );
    } catch (e) {
      return _catch(e);
    }
  }

  @override
  Future<Either<Failure, ServiceChatMessagesModel>> getMessages({
    required int conversationId,
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      return Right(
        await dataSource.getMessages(
          conversationId: conversationId,
          page: page,
          perPage: perPage,
        ),
      );
    } catch (e) {
      return _catch(e);
    }
  }

  @override
  Future<Either<Failure, SendServiceChatMessageModel>> sendMessage({
    required int conversationId,
    required String body,
    File? imageFile,
  }) async {
    try {
      return Right(
        await dataSource.sendMessage(
          conversationId: conversationId,
          body: body,
          imageFile: imageFile,
        ),
      );
    } catch (e) {
      return _catch(e);
    }
  }
}
