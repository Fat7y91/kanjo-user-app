class NotificationModel {
  final String id;
  final String type;
  final String channel;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String? sentAt;
  final String? readAt;
  final String createdAt;
  final String updatedAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.channel,
    required this.title,
    required this.body,
    required this.data,
    this.sentAt,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isRead => readAt != null && readAt!.trim().isNotEmpty;

  String get relatedId {
    final orderId = data['order_id'] ?? data['service_order_id'];
    return orderId?.toString() ?? '';
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : <String, dynamic>{};

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? data['type']?.toString() ?? '',
      channel: json['channel']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? json['message']?.toString() ?? '',
      data: data,
      sentAt: json['sent_at']?.toString(),
      readAt: json['read_at']?.toString(),
      createdAt:
          json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt:
          json['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'channel': channel,
        'title': title,
        'body': body,
        'data': data,
        'sent_at': sentAt,
        'read_at': readAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
