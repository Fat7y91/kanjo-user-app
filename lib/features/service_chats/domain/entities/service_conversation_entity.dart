import 'package:heraj/features/conversations/domain/entities/conversation_websocket_entity.dart';

class ServiceConversationEntity {
  final int id;
  final int serviceProviderId;
  final String providerName;
  final int userId;
  final String userName;
  final String status;
  final String? lastMessageAt;
  final bool providerHasUnread;
  final bool userHasUnread;
  final int providerUnreadCount;
  final int userUnreadCount;
  final String? providerLastReadAt;
  final String? userLastReadAt;
  final int? providerLastReadMessageId;
  final int? userLastReadMessageId;
  final int? latestMessageId;
  final ConversationWebsocketEntity websocket;

  const ServiceConversationEntity({
    required this.id,
    required this.serviceProviderId,
    required this.providerName,
    required this.userId,
    required this.userName,
    required this.status,
    this.lastMessageAt,
    required this.providerHasUnread,
    required this.userHasUnread,
    this.providerUnreadCount = 0,
    this.userUnreadCount = 0,
    this.providerLastReadAt,
    this.userLastReadAt,
    this.providerLastReadMessageId,
    this.userLastReadMessageId,
    this.latestMessageId,
    this.websocket = const ConversationWebsocketEntity(channel: '', event: ''),
  });

  bool get isOpen => status.toLowerCase() == 'open';

  ServiceConversationEntity copyWith({
    int? id,
    int? serviceProviderId,
    String? providerName,
    int? userId,
    String? userName,
    String? status,
    String? lastMessageAt,
    bool? providerHasUnread,
    bool? userHasUnread,
    int? providerUnreadCount,
    int? userUnreadCount,
    String? providerLastReadAt,
    String? userLastReadAt,
    int? providerLastReadMessageId,
    int? userLastReadMessageId,
    int? latestMessageId,
    ConversationWebsocketEntity? websocket,
  }) {
    return ServiceConversationEntity(
      id: id ?? this.id,
      serviceProviderId: serviceProviderId ?? this.serviceProviderId,
      providerName: providerName ?? this.providerName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      status: status ?? this.status,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      providerHasUnread: providerHasUnread ?? this.providerHasUnread,
      userHasUnread: userHasUnread ?? this.userHasUnread,
      providerUnreadCount: providerUnreadCount ?? this.providerUnreadCount,
      userUnreadCount: userUnreadCount ?? this.userUnreadCount,
      providerLastReadAt: providerLastReadAt ?? this.providerLastReadAt,
      userLastReadAt: userLastReadAt ?? this.userLastReadAt,
      providerLastReadMessageId:
          providerLastReadMessageId ?? this.providerLastReadMessageId,
      userLastReadMessageId:
          userLastReadMessageId ?? this.userLastReadMessageId,
      latestMessageId: latestMessageId ?? this.latestMessageId,
      websocket: websocket ?? this.websocket,
    );
  }

  factory ServiceConversationEntity.fromJson(Map<String, dynamic> json) {
    final websocketJson = json['websocket'];
    return ServiceConversationEntity(
      id: _asInt(json['id']),
      serviceProviderId: _asInt(json['service_provider_id']),
      providerName: json['provider_name']?.toString() ?? '',
      userId: _asInt(json['user_id']),
      userName: json['user_name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      lastMessageAt: json['last_message_at']?.toString(),
      providerHasUnread: json['provider_has_unread'] == true,
      userHasUnread: json['user_has_unread'] == true,
      providerUnreadCount: _asInt(json['provider_unread_count']),
      userUnreadCount: _asInt(json['user_unread_count']),
      providerLastReadAt: json['provider_last_read_at']?.toString(),
      userLastReadAt: json['user_last_read_at']?.toString(),
      providerLastReadMessageId:
          _asNullableInt(json['provider_last_read_message_id']),
      userLastReadMessageId: _asNullableInt(json['user_last_read_message_id']),
      latestMessageId: _asNullableInt(json['latest_message_id']),
      websocket: ConversationWebsocketEntity.fromJson(
        websocketJson is Map ? Map<String, dynamic>.from(websocketJson) : null,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_provider_id': serviceProviderId,
      'provider_name': providerName,
      'user_id': userId,
      'user_name': userName,
      'status': status,
      'last_message_at': lastMessageAt,
      'provider_has_unread': providerHasUnread,
      'user_has_unread': userHasUnread,
      'provider_unread_count': providerUnreadCount,
      'user_unread_count': userUnreadCount,
      'provider_last_read_at': providerLastReadAt,
      'user_last_read_at': userLastReadAt,
      'provider_last_read_message_id': providerLastReadMessageId,
      'user_last_read_message_id': userLastReadMessageId,
      'latest_message_id': latestMessageId,
      'websocket': websocket.toJson(),
    };
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
