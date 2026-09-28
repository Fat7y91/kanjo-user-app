import '../../../products/domain/entities/localized_name_entity.dart';

class CartVariantEntity {
  final int id;
  final LocalizedNameEntity name;
  final double price;
  final String? imageUrl;

  const CartVariantEntity({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
  });

  factory CartVariantEntity.fromJson(Map<String, dynamic> json) {
    return CartVariantEntity(
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
      imageUrl: json['image_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name.toJson(),
        'price': price,
        'image_url': imageUrl,
      };
}
