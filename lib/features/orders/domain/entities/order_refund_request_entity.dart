import 'package:flutter/foundation.dart';

@immutable
class OrderRefundRequestEntity {
  final int id;
  final String status;
  final String reason;
  final DateTime? createdAt;

  const OrderRefundRequestEntity({
    required this.id,
    this.status = '',
    this.reason = '',
    this.createdAt,
  });

  factory OrderRefundRequestEntity.fromJson(Map<String, dynamic> json) {
    return OrderRefundRequestEntity(
      id: _id(json['id']),
      status: json['status']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'reason': reason,
        'created_at': createdAt?.toIso8601String(),
      };
}

int _id(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
