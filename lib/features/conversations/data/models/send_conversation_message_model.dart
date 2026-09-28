import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/conversation_message_entity.dart';

class SendConversationMessageModel {
  final ConversationMessageEntity message;
  final ConversationEntity? conversation;

  const SendConversationMessageModel({
    required this.message,
    this.conversation,
  });

  factory SendConversationMessageModel.fromJson(Map<String, dynamic> json) {
    final nested = json['data'];
    final Map<String, dynamic> payload;
    if (nested is Map) {
      payload = Map<String, dynamic>.from(nested);
    } else {
      payload = json;
    }

    final realtime = payload['realtime'];
    ConversationEntity? conversation;
    Map<String, dynamic> messageJson = payload;

    if (realtime is Map) {
      final realtimeMap = Map<String, dynamic>.from(realtime);
      final conversationJson = realtimeMap['conversation'];
      if (conversationJson is Map) {
        conversation = ConversationEntity.fromJson(
          Map<String, dynamic>.from(conversationJson),
        );
      }
      final realtimeMessage = realtimeMap['message'];
      if (realtimeMessage is Map) {
        messageJson = Map<String, dynamic>.from(realtimeMessage);
      }
    }

    return SendConversationMessageModel(
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
