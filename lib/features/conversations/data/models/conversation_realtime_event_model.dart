import 'dart:convert';

import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/conversation_message_entity.dart';

class ChatRealtimePayload {
  final String event;
  final Map<String, dynamic> conversationJson;
  final ConversationMessageEntity message;

  const ChatRealtimePayload({
    required this.event,
    required this.conversationJson,
    required this.message,
  });

  bool get isVendorConversation => _hasId(conversationJson['vendor_id']);

  bool get isServiceConversation =>
      _hasId(conversationJson['service_provider_id']);

  ConversationRealtimeEventModel? asVendorEvent() {
    if (!isVendorConversation) return null;
    return ConversationRealtimeEventModel(
      event: event,
      conversation: ConversationEntity.fromJson(conversationJson),
      message: message,
    );
  }

  static ChatRealtimePayload? tryParse(dynamic raw) {
    try {
      var json = _asJsonMap(raw);
      if (json == null) return null;

      if (json['conversation'] == null && json['data'] != null) {
        json = _asJsonMap(json['data']) ?? json;
      }

      final conversationJson = json['conversation'];
      final messageJson = json['message'];
      if (conversationJson is! Map || messageJson is! Map) {
        return null;
      }

      return ChatRealtimePayload(
        event: json['event']?.toString() ?? '',
        conversationJson: Map<String, dynamic>.from(conversationJson),
        message: ConversationMessageEntity.fromJson(
          Map<String, dynamic>.from(messageJson),
        ),
      );
    } catch (_) {}
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'event': event,
      'conversation': conversationJson,
      'message': message.toJson(),
    };
  }
}

class ConversationRealtimeEventModel {
  final String event;
  final ConversationEntity conversation;
  final ConversationMessageEntity message;

  const ConversationRealtimeEventModel({
    required this.event,
    required this.conversation,
    required this.message,
  });

  factory ConversationRealtimeEventModel.fromJson(Map<String, dynamic> json) {
    final conversationJson = json['conversation'];
    final messageJson = json['message'];

    return ConversationRealtimeEventModel(
      event: json['event']?.toString() ?? '',
      conversation: ConversationEntity.fromJson(
        conversationJson is Map<String, dynamic>
            ? conversationJson
            : Map<String, dynamic>.from(conversationJson as Map),
      ),
      message: ConversationMessageEntity.fromJson(
        messageJson is Map<String, dynamic>
            ? messageJson
            : Map<String, dynamic>.from(messageJson as Map),
      ),
    );
  }

  static ConversationRealtimeEventModel? tryParse(dynamic raw) {
    return ChatRealtimePayload.tryParse(raw)?.asVendorEvent();
  }

  Map<String, dynamic> toJson() {
    return {
      'event': event,
      'conversation': conversation.toJson(),
      'message': message.toJson(),
    };
  }
}

Map<String, dynamic>? _asJsonMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  if (raw is String && raw.trim().isNotEmpty) {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  }
  return null;
}

bool _hasId(dynamic value) {
  if (value == null) return false;
  if (value is int) return value > 0;
  return (int.tryParse(value.toString()) ?? 0) > 0;
}
