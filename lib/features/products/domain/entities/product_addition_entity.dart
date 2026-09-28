import 'localized_name_entity.dart';

class ProductAdditionEntity {
  final int id;
  final LocalizedNameEntity name;
  final double price;
  final int sortOrder;

  const ProductAdditionEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.sortOrder,
  });

  factory ProductAdditionEntity.fromJson(Map<String, dynamic> json) {
    return ProductAdditionEntity(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: LocalizedNameEntity.fromJson(
        json['name'] is Map<String, dynamic>
            ? json['name'] as Map<String, dynamic>
            : null,
      ),
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '') ?? 0,
      sortOrder: json['sort_order'] is int
          ? json['sort_order'] as int
          : int.tryParse(json['sort_order']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name.toJson(),
        'price': price,
        'sort_order': sortOrder,
      };
}
