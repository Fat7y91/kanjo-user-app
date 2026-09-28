import '../../domain/entities/support_ticket_message_entity.dart';

class SupportTicketModel {
  const SupportTicketModel({
    required this.id,
    required this.userId,
    required this.userType,
    required this.title,
    required this.description,
    required this.status,
    required this.messagesCount,
    this.attachment,
    this.createdAt,
    this.updatedAt,
    this.messages = const [],
  });

  final int id;
  final int userId;
  final String userType;
  final String title;
  final String description;
  final String status;
  final String? attachment;
  final int messagesCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<SupportTicketMessageEntity> messages;

  bool get isClosed {
    final value = status.toLowerCase().trim();
    return value == 'closed' || value == 'resolved' || value == 'cancelled';
  }

  String get statusLabel {
    switch (status.toLowerCase().trim()) {
      case 'pending':
        return 'Pending';
      case 'open':
        return 'Open';
      case 'answered':
        return 'Answered';
      case 'in_progress':
        return 'In progress';
      case 'closed':
        return 'Closed';
      case 'resolved':
        return 'Resolved';
      default:
        return status.isEmpty ? 'Pending' : status;
    }
  }

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    final messages = json['messages'] is List
        ? (json['messages'] as List)
            .whereType<Map>()
            .map(
              (e) => SupportTicketMessageEntity.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList()
        : const <SupportTicketMessageEntity>[];
    return SupportTicketModel(
      id: _intFrom(json['id']),
      userId: _intFrom(json['user_id']),
      userType: json['user_type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      attachment: _nullableString(json['attachment']),
      messagesCount: json['messages_count'] != null
          ? _intFrom(json['messages_count'])
          : messages.length,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      messages: messages,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_type': userType,
        'title': title,
        'description': description,
        'status': status,
        'attachment': attachment,
        'messages_count': messagesCount,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'messages': messages.map((e) => e.toJson()).toList(),
      };
}

int _intFrom(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _nullableString(dynamic value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty || text == 'null') return null;
  return text;
}
