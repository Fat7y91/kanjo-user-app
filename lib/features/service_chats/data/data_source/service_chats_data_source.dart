import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

import '../../../../../config/api_path.dart';
import '../../../../../core/service/webservice/dio_helper.dart';
import '../../domain/entities/service_conversation_entity.dart';
import '../models/send_service_chat_message_model.dart';
import '../models/service_chat_messages_model.dart';
import '../models/service_conversations_list_model.dart';

abstract class ServiceChatsDataSource {
  Future<ServiceConversationEntity> startConversation(int serviceProviderId);

  Future<ServiceConversationsListModel> getConversations({
    int page = 1,
    int perPage = 20,
  });

  Future<ServiceChatMessagesModel> getMessages({
    required int conversationId,
    int page = 1,
    int perPage = 50,
  });

  Future<SendServiceChatMessageModel> sendMessage({
    required int conversationId,
    required String body,
    File? imageFile,
  });
}

class ServiceChatsDataSourceImp extends ServiceChatsDataSource {
  ServiceChatsDataSourceImp({required this.apiService});

  final ApiService apiService;

  @override
  Future<ServiceConversationEntity> startConversation(
    int serviceProviderId,
  ) async {
    final res = await apiService.post(
      url: ApiPath.startServiceConversation(serviceProviderId),
      requestBody: const <String, dynamic>{},
      returnDataOnly: true,
    );
    if (res is! Map) {
      throw Exception('Invalid conversation response');
    }
    return ServiceConversationEntity.fromJson(Map<String, dynamic>.from(res));
  }

  @override
  Future<ServiceConversationsListModel> getConversations({
    int page = 1,
    int perPage = 20,
  }) async {
    final res = await apiService.get(
      url: ApiPath.getServiceConversationsList(page: page, perPage: perPage),
      returnDataOnly: false,
    );
    if (res is! Map) {
      return ServiceConversationsListModel.fromJson(const {});
    }
    return ServiceConversationsListModel.fromJson(
      Map<String, dynamic>.from(res),
    );
  }

  @override
  Future<ServiceChatMessagesModel> getMessages({
    required int conversationId,
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final res = await apiService.get(
        url: ApiPath.getServiceConversationMessages(
          conversationId,
          page: page,
          perPage: perPage,
        ),
        returnDataOnly: false,
      );
      if (res is! Map) {
        return ServiceChatMessagesModel.fromJson(const {});
      }
      return ServiceChatMessagesModel.fromJson(Map<String, dynamic>.from(res));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return ServiceChatMessagesModel.fromJson(const {});
      }
      rethrow;
    }
  }

  @override
  Future<SendServiceChatMessageModel> sendMessage({
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
      url: ApiPath.sendServiceConversationMessage(conversationId),
      requestBody: requestBody,
      returnDataOnly: false,
    );
    if (res is! Map) {
      throw Exception('Invalid message response');
    }
    return SendServiceChatMessageModel.fromJson(
      Map<String, dynamic>.from(res),
    );
  }
}
