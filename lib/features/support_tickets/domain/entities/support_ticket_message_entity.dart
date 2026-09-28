class SupportTicketMessageEntity {
  const SupportTicketMessageEntity({
    required this.id,
    required this.senderUserId,
    required this.senderRole,
    required this.message,
    this.createdAt,
  });

  final int id;
  final int senderUserId;
  final String senderRole;
  final String message;
  final DateTime? createdAt;

  bool get isCustomer {
    final role = senderRole.toLowerCase().trim();
    return role == 'customer' || role == 'user' || role == 'client';
  }

  factory SupportTicketMessageEntity.fromJson(Map<String, dynamic> json) {
    return SupportTicketMessageEntity(
      id: _intFrom(json['id']),
      senderUserId: _intFrom(json['sender_user_id']),
      senderRole: json['sender_role']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender_user_id': senderUserId,
        'sender_role': senderRole,
        'message': message,
        'created_at': createdAt?.toIso8601String(),
      };
}

int _intFrom(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
