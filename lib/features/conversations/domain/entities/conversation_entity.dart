import 'conversation_websocket_entity.dart';

class ConversationEntity {
  final int id;
  final int vendorId;
  final String vendorName;
  final String vendorSlug;
  final int userId;
  final String userName;
  final String status;
  final String? lastMessageAt;
  final bool vendorHasUnread;
  final bool userHasUnread;
  final String? vendorLastReadAt;
  final String? userLastReadAt;
  final int? vendorLastReadMessageId;
  final int? userLastReadMessageId;
  final int? latestMessageId;
  final ConversationWebsocketEntity websocket;

  const ConversationEntity({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.vendorSlug,
    required this.userId,
    required this.userName,
    required this.status,
    this.lastMessageAt,
    required this.vendorHasUnread,
    required this.userHasUnread,
    this.vendorLastReadAt,
    this.userLastReadAt,
    this.vendorLastReadMessageId,
    this.userLastReadMessageId,
    this.latestMessageId,
    this.websocket = const ConversationWebsocketEntity(channel: '', event: ''),
  });

  bool get isOpen => status.toLowerCase() == 'open';

  ConversationEntity copyWith({
    int? id,
    int? vendorId,
    String? vendorName,
    String? vendorSlug,
    int? userId,
    String? userName,
    String? status,
    String? lastMessageAt,
    bool? vendorHasUnread,
    bool? userHasUnread,
    String? vendorLastReadAt,
    String? userLastReadAt,
    int? vendorLastReadMessageId,
    int? userLastReadMessageId,
    int? latestMessageId,
    ConversationWebsocketEntity? websocket,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      vendorSlug: vendorSlug ?? this.vendorSlug,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      status: status ?? this.status,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      vendorHasUnread: vendorHasUnread ?? this.vendorHasUnread,
      userHasUnread: userHasUnread ?? this.userHasUnread,
      vendorLastReadAt: vendorLastReadAt ?? this.vendorLastReadAt,
      userLastReadAt: userLastReadAt ?? this.userLastReadAt,
      vendorLastReadMessageId:
          vendorLastReadMessageId ?? this.vendorLastReadMessageId,
      userLastReadMessageId:
          userLastReadMessageId ?? this.userLastReadMessageId,
      latestMessageId: latestMessageId ?? this.latestMessageId,
      websocket: websocket ?? this.websocket,
    );
  }

  factory ConversationEntity.fromJson(Map<String, dynamic> json) {
    final websocketJson = json['websocket'];
    return ConversationEntity(
      id: _asInt(json['id']),
      vendorId: _asInt(json['vendor_id']),
      vendorName: json['vendor_name']?.toString() ?? '',
      vendorSlug: json['vendor_slug']?.toString() ?? '',
      userId: _asInt(json['user_id']),
      userName: json['user_name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      lastMessageAt: json['last_message_at']?.toString(),
      vendorHasUnread: json['vendor_has_unread'] == true,
      userHasUnread: json['user_has_unread'] == true,
      vendorLastReadAt: json['vendor_last_read_at']?.toString(),
      userLastReadAt: json['user_last_read_at']?.toString(),
      vendorLastReadMessageId: _asNullableInt(json['vendor_last_read_message_id']),
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
      'vendor_id': vendorId,
      'vendor_name': vendorName,
      'vendor_slug': vendorSlug,
      'user_id': userId,
      'user_name': userName,
      'status': status,
      'last_message_at': lastMessageAt,
      'vendor_has_unread': vendorHasUnread,
      'user_has_unread': userHasUnread,
      'vendor_last_read_at': vendorLastReadAt,
      'user_last_read_at': userLastReadAt,
      'vendor_last_read_message_id': vendorLastReadMessageId,
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
