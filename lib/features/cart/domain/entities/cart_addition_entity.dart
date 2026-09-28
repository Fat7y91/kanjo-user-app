import '../../../products/domain/entities/localized_name_entity.dart';

class CartAdditionEntity {
  final int id;
  final LocalizedNameEntity name;
  final double price;

  const CartAdditionEntity({
    required this.id,
    required this.name,
    required this.price,
  });

  factory CartAdditionEntity.fromJson(Map<String, dynamic> json) {
    return CartAdditionEntity(
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
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name.toJson(),
        'price': price,
      };
}
