import '../../../products/data/models/product_model.dart';

class WishlistItemModel {
  final int id;
  final int productId;
  final int? productVariantId;
  final DateTime? createdAt;
  final ProductModel? product;

  const WishlistItemModel({
    required this.id,
    required this.productId,
    this.productVariantId,
    this.createdAt,
    this.product,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      productId: json['product_id'] is int
          ? json['product_id'] as int
          : int.tryParse(json['product_id']?.toString() ?? '') ?? 0,
      productVariantId: json['product_variant_id'] is int
          ? json['product_variant_id'] as int
          : int.tryParse(json['product_variant_id']?.toString() ?? ''),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      product: json['product'] is Map<String, dynamic>
          ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'product_variant_id': productVariantId,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (product != null) 'product': product!.toJson(),
      };
}
