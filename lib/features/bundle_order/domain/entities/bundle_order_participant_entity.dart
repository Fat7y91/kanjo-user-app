import 'bundle_order_item_entity.dart';

class BundleOrderParticipantEntity {
  final int userId;
  final String name;
  final List<BundleOrderItemEntity> items;
  final double subtotal;

  const BundleOrderParticipantEntity({
    required this.userId,
    required this.name,
    required this.items,
    required this.subtotal,
  });

  factory BundleOrderParticipantEntity.fromJson(Map<String, dynamic> json) {
    return BundleOrderParticipantEntity(
      userId: _intFrom(json['user_id'] ?? json['userId']),
      name: json['name']?.toString() ?? '',
      items: (json['items'] as List?)
              ?.whereType<Map>()
              .map(
                (e) => BundleOrderItemEntity.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
      subtotal: _doubleFrom(json['subtotal']),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'items': items.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
      };

  static int _intFrom(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _doubleFrom(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
