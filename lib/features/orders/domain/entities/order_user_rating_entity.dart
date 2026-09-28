import 'package:flutter/foundation.dart';

@immutable
class OrderUserRatingEntity {
  final int id;
  final double rating;
  final String comment;
  final int? orderId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderUserRatingEntity({
    required this.id,
    required this.rating,
    this.comment = '',
    this.orderId,
    this.createdAt,
    this.updatedAt,
  });

  int get ratingOutOf5 {
    if (rating <= 0) return 0;
    return rating.round().clamp(1, 5);
  }

  factory OrderUserRatingEntity.fromJson(Map<String, dynamic> json) {
    return OrderUserRatingEntity(
      id: _id(json['id']),
      rating: _rating(json['rating']),
      comment: json['comment']?.toString().trim() ?? '',
      orderId: _nullableId(json['order_id']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'rating': rating,
        'comment': comment,
        'order_id': orderId,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}

int _id(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _nullableId(dynamic value) {
  if (value == null) return null;
  final parsed = _id(value);
  return parsed == 0 ? null : parsed;
}

double _rating(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
