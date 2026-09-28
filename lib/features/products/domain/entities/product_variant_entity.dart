import 'localized_name_entity.dart';

class ProductVariantEntity {
  final int id;
  final String sku;
  final LocalizedNameEntity name;
  final double price;
  final String? image;
  final String? imageUrl;
  final bool isActive;
  final bool isOutOfStock;
  final bool isOrderable;
  final int sortOrder;

  const ProductVariantEntity({
    required this.id,
    required this.sku,
    required this.name,
    required this.price,
    this.image,
    this.imageUrl,
    required this.isActive,
    required this.isOutOfStock,
    required this.isOrderable,
    required this.sortOrder,
  });

  factory ProductVariantEntity.fromJson(Map<String, dynamic> json) {
    return ProductVariantEntity(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      sku: json['sku']?.toString() ?? '',
      name: LocalizedNameEntity.fromJson(
        json['name'] is Map<String, dynamic>
            ? json['name'] as Map<String, dynamic>
            : null,
      ),
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '') ?? 0,
      image: json['image']?.toString(),
      imageUrl: json['image_url']?.toString(),
      isActive: json['is_active'] != false,
      isOutOfStock: json['is_out_of_stock'] == true,
      isOrderable: json['is_orderable'] != false,
      sortOrder: json['sort_order'] is int
          ? json['sort_order'] as int
          : int.tryParse(json['sort_order']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sku': sku,
        'name': name.toJson(),
        'price': price,
        'image': image,
        'image_url': imageUrl,
        'is_active': isActive,
        'is_out_of_stock': isOutOfStock,
        'is_orderable': isOrderable,
        'sort_order': sortOrder,
      };
}
