import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

import '../../../../../config/api_path.dart';
import '../../../../../core/models/paginated_response.dart';
import '../../../../../core/service/webservice/dio_helper.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/conversation_message_entity.dart';
import '../models/conversations_list_model.dart';
import '../models/send_conversation_message_model.dart';

abstract class ConversationsDataSource {
  Future<ConversationEntity> startConversation(int vendorId);

  Future<ConversationsListModel> getConversations({
    int page = 1,
    int perPage = 50,
  });

  Future<PaginatedResponse<ConversationMessageEntity>> getMessages({
    required int conversationId,
    int page = 1,
    int perPage = 50,
  });

  Future<SendConversationMessageModel> sendMessage({
    required int conversationId,
    required String body,
    File? imageFile,
  });

  Future<void> acceptQuote({
    required int conversationId,
    required int quoteMessageId,
  });
}

class ConversationsDataSourceImp extends ConversationsDataSource {
  ConversationsDataSourceImp({required this.apiService});

  final ApiService apiService;

  @override
  Future<ConversationEntity> startConversation(int vendorId) async {
    final res = await apiService.post(
      url: ApiPath.startVendorConversation(vendorId),
      requestBody: const <String, dynamic>{},
      returnDataOnly: true,
    );
    if (res is! Map) {
      throw Exception('Invalid conversation response');
    }
    return ConversationEntity.fromJson(Map<String, dynamic>.from(res));
  }

  @override
  Future<ConversationsListModel> getConversations({
    int page = 1,
    int perPage = 50,
  }) async {
    final res = await apiService.get(
      url: ApiPath.getConversationsList(page: page, perPage: perPage),
      returnDataOnly: false,
    );
    if (res is! Map) {
      return ConversationsListModel.fromJson(const {});
    }
    return ConversationsListModel.fromJson(Map<String, dynamic>.from(res));
  }

  @override
  Future<PaginatedResponse<ConversationMessageEntity>> getMessages({
    required int conversationId,
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final res = await apiService.get(
        url: ApiPath.getConversationMessages(
          conversationId,
          page: page,
          perPage: perPage,
        ),
        returnDataOnly: false,
      );
      return parsePaginatedResponse(
        res,
        ConversationMessageEntity.fromJson,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return PaginatedResponse.empty(perPage: perPage);
      }
      rethrow;
    }
  }

  @override
  Future<SendConversationMessageModel> sendMessage({
    required int conversationId,
    required String body,
    File? imageFile,
  }) async {
    final image = imageFile;
    final Object requestBody;
    if (image != null && image.path.isNotEmpty) {
      requestBody = FormData.fromMap({
        'body': body,
        'image': await MultipartFile.fromFile(
          image.path,
          filename: path.basename(image.path),
        ),
      });
    } else {
      requestBody = {
        'body': body,
        'image': null,
      };
    }

    final res = await apiService.post(
      url: ApiPath.sendConversationMessage(conversationId),
      requestBody: requestBody,
      returnDataOnly: false,
    );
    if (res is! Map) {
      throw Exception('Invalid message response');
    }
    return SendConversationMessageModel.fromJson(
      Map<String, dynamic>.from(res),
    );
  }

  @override
  Future<void> acceptQuote({
    required int conversationId,
    required int quoteMessageId,
  }) async {
    await apiService.post(
      url: ApiPath.acceptConversationQuote(
        conversationId: conversationId,
        quoteMessageId: quoteMessageId,
      ),
      requestBody: const <String, dynamic>{},
      returnDataOnly: false,
    );
  }
}
