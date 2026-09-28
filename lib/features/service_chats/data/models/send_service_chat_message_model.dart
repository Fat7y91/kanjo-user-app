import 'package:heraj/features/conversations/domain/entities/conversation_message_entity.dart';
import 'package:heraj/features/service_chats/domain/entities/service_conversation_entity.dart';

class SendServiceChatMessageModel {
  final ConversationMessageEntity message;
  final ServiceConversationEntity? conversation;

  const SendServiceChatMessageModel({
    required this.message,
    this.conversation,
  });

  factory SendServiceChatMessageModel.fromJson(Map<String, dynamic> json) {
    final nested = json['data'];
    final Map<String, dynamic> payload;
    if (nested is Map) {
      payload = Map<String, dynamic>.from(nested);
    } else {
      payload = json;
    }

    ServiceConversationEntity? conversation;
    Map<String, dynamic>? messageJson;

    final realtime = payload['realtime'];
    if (realtime is Map) {
      final realtimeMap = Map<String, dynamic>.from(realtime);
      final conversationJson = realtimeMap['conversation'];
      if (conversationJson is Map) {
        conversation = ServiceConversationEntity.fromJson(
          Map<String, dynamic>.from(conversationJson),
        );
      }
      final realtimeMessage = realtimeMap['message'];
      if (realtimeMessage is Map) {
        messageJson = Map<String, dynamic>.from(realtimeMessage);
      }
    }

    final conversationJson = payload['conversation'];
    if (conversation == null && conversationJson is Map) {
      conversation = ServiceConversationEntity.fromJson(
        Map<String, dynamic>.from(conversationJson),
      );
    }

    if (messageJson == null && _looksLikeMessage(payload)) {
      messageJson = payload;
    }

    if (messageJson == null) {
      final items = payload['items'];
      if (items is List && items.isNotEmpty && items.first is Map) {
        final first = Map<String, dynamic>.from(items.first as Map);
        if (_looksLikeMessage(first)) {
          messageJson = first;
        }
      }
    }

    if (messageJson == null) {
      throw Exception('Invalid message response');
    }

    return SendServiceChatMessageModel(
      message: ConversationMessageEntity.fromJson(messageJson),
      conversation: conversation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...message.toJson(),
      if (conversation != null) 'conversation': conversation!.toJson(),
    };
  }
}

bool _looksLikeMessage(Map<String, dynamic> json) {
  return json.containsKey('sender_role') ||
      json.containsKey('sender_user_id') ||
      json.containsKey('message_type') ||
      json.containsKey('websocket_event');
}
