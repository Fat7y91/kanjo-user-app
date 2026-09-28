import '../../../products/domain/entities/localized_name_entity.dart';

class OrderAdditionEntity {
  const OrderAdditionEntity({
    required this.id,
    required this.name,
    required this.unitPrice,
  });

  final int id;
  final LocalizedNameEntity name;
  final double unitPrice;

  factory OrderAdditionEntity.fromJson(Map<String, dynamic> json) {
    return OrderAdditionEntity(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: LocalizedNameEntity.fromJson(
        json['addition_name'] is Map
            ? Map<String, dynamic>.from(json['addition_name'] as Map)
            : json['name'] is Map
                ? Map<String, dynamic>.from(json['name'] as Map)
                : null,
      ),
      unitPrice: _money(json['unit_price'] ?? json['price']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'addition_name': name.toJson(),
        'unit_price': unitPrice,
      };
}

double _money(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
