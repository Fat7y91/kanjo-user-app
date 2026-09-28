import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/models/paginated_response.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/conversation_message_entity.dart';
import '../../domain/repo/conversations_repo.dart';
import '../data_source/conversations_data_source.dart';
import '../models/conversations_list_model.dart';
import '../models/send_conversation_message_model.dart';

class ConversationsRepoImp extends ConversationsRepo {
  ConversationsRepoImp({required this.dataSource});

  final ConversationsDataSource dataSource;

  Either<Failure, T> _catch<T>(Object e) {
    if (e is DioException) {
      return Left(ServerFailure.fromDioError(e));
    }
    return Left(GeneralError(e));
  }

  @override
  Future<Either<Failure, ConversationEntity>> startConversation(
    int vendorId,
  ) async {
    try {
      return Right(await dataSource.startConversation(vendorId));
    } catch (e) {
      return _catch(e);
    }
  }

  @override
  Future<Either<Failure, ConversationsListModel>> getConversations({
    int page = 1,
    int perPage = 50,
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
  Future<Either<Failure, PaginatedResponse<ConversationMessageEntity>>>
      getMessages({
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
  Future<Either<Failure, SendConversationMessageModel>> sendMessage({
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

  @override
  Future<Either<Failure, Unit>> acceptQuote({
    required int conversationId,
    required int quoteMessageId,
  }) async {
    try {
      await dataSource.acceptQuote(
        conversationId: conversationId,
        quoteMessageId: quoteMessageId,
      );
      return const Right(unit);
    } catch (e) {
      return _catch(e);
    }
  }
}
