class ConversationMessageEntity {
  final int id;
  final String senderRole;
  final int senderUserId;
  final String messageType;
  final String body;
  final String? image;
  final Map<String, dynamic>? meta;
  final String? createdAt;
  final String websocketEvent;

  const ConversationMessageEntity({
    required this.id,
    required this.senderRole,
    required this.senderUserId,
    required this.messageType,
    required this.body,
    this.image,
    this.meta,
    this.createdAt,
    this.websocketEvent = '',
  });

  bool get isFromCustomer => senderRole.toLowerCase() == 'customer';

  bool get isQuote {
    final type = messageType.toLowerCase();
    return type.contains('quote');
  }

  bool get isQuoteAccepted {
    final status = meta?['status']?.toString().toLowerCase() ?? '';
    return status == 'accepted' || meta?['accepted'] == true;
  }

  String? get imageUrl {
    final value = image?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  double? get quoteAmount {
    final value = meta?['amount'] ?? meta?['total'] ?? meta?['price'];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  ConversationMessageEntity copyWith({
    int? id,
    String? senderRole,
    int? senderUserId,
    String? messageType,
    String? body,
    String? image,
    Map<String, dynamic>? meta,
    String? createdAt,
    String? websocketEvent,
  }) {
    return ConversationMessageEntity(
      id: id ?? this.id,
      senderRole: senderRole ?? this.senderRole,
      senderUserId: senderUserId ?? this.senderUserId,
      messageType: messageType ?? this.messageType,
      body: body ?? this.body,
      image: image ?? this.image,
      meta: meta ?? this.meta,
      createdAt: createdAt ?? this.createdAt,
      websocketEvent: websocketEvent ?? this.websocketEvent,
    );
  }

  factory ConversationMessageEntity.fromJson(Map<String, dynamic> json) {
    final metaJson = json['meta'];
    return ConversationMessageEntity(
      id: _asInt(json['id']),
      senderRole: json['sender_role']?.toString() ?? '',
      senderUserId: _asInt(json['sender_user_id']),
      messageType: json['message_type']?.toString() ?? 'text',
      body: json['body']?.toString() ?? '',
      image: _parseImage(json['image']),
      meta: metaJson is Map ? Map<String, dynamic>.from(metaJson) : null,
      createdAt: json['created_at']?.toString(),
      websocketEvent: json['websocket_event']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_role': senderRole,
      'sender_user_id': senderUserId,
      'message_type': messageType,
      'body': body,
      'image': image,
      'meta': meta,
      'created_at': createdAt,
      'websocket_event': websocketEvent,
    };
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _parseImage(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    final image = value.trim();
    return image.isEmpty ? null : image;
  }
  if (value is Map) {
    final image = value['url']?.toString().trim();
    if (image == null || image.isEmpty) {
      return null;
    }
    return image;
  }
  return null;
}
