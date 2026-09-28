import '../../data/models/notifications_model.dart';

class NotificationEntity {
  final String id;
  final String type;
  final String channel;
  final String title;
  final String message;
  final bool isRead;
  final String relatedId;
  final Map<String, dynamic> data;
  final DateTime? createdAt;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.channel,
    required this.title,
    required this.message,
    required this.isRead,
    required this.relatedId,
    required this.data,
    this.createdAt,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    final model = NotificationModel.fromJson(json);
    return NotificationEntity.fromNotificationModel(model);
  }

  factory NotificationEntity.fromNotificationModel(NotificationModel model) {
    return NotificationEntity(
      id: model.id,
      type: model.type,
      channel: model.channel,
      title: model.title,
      message: model.body,
      isRead: model.isRead,
      relatedId: model.relatedId,
      data: model.data,
      createdAt: DateTime.tryParse(model.createdAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'channel': channel,
        'title': title,
        'body': message,
        'data': data,
        'read_at': isRead ? createdAt?.toIso8601String() : null,
        'created_at': createdAt?.toIso8601String(),
      };

  NotificationEntity copyWith({bool? isRead}) {
    return NotificationEntity(
      id: id,
      type: type,
      channel: channel,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId,
      data: data,
      createdAt: createdAt,
    );
  }
}
