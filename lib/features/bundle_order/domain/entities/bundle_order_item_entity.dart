import '../../../products/domain/entities/localized_name_entity.dart';

class BundleOrderItemEntity {
  final int id;
  final int productId;
  final int? productVariantId;
  final LocalizedNameEntity productName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final int? userId;
  final String userName;
  final int vendorId;
  final String vendorName;

  const BundleOrderItemEntity({
    required this.id,
    required this.productId,
    this.productVariantId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.userId,
    this.userName = '',
    this.vendorId = 0,
    this.vendorName = '',
  });

  String localizedName([String? languageCode]) =>
      productName.localized(languageCode);

  factory BundleOrderItemEntity.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    LocalizedNameEntity name = const LocalizedNameEntity(ar: '', en: '');
    if (product is Map) {
      final productMap = Map<String, dynamic>.from(product);
      if (productMap['name'] is Map) {
        name = LocalizedNameEntity.fromJson(
          Map<String, dynamic>.from(productMap['name'] as Map),
        );
      }
    }

    return BundleOrderItemEntity(
      id: _intFrom(json['id']),
      productId: _intFrom(json['product_id'] ?? json['productId']),
      productVariantId: json['product_variant_id'] == null
          ? null
          : _intFrom(json['product_variant_id']),
      productName: name,
      quantity: _intFrom(json['quantity'] ?? json['qty'], fallback: 1),
      unitPrice: _doubleFrom(json['unit_price'] ?? json['price']),
      lineTotal: _doubleFrom(json['line_total'] ?? json['total']),
      userId: json['user_id'] == null && json['userId'] == null
          ? null
          : _intFrom(json['user_id'] ?? json['userId']),
      userName: json['user_name']?.toString() ?? '',
      vendorId: _intFrom(json['vendor_id']),
      vendorName: json['vendor_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'product_variant_id': productVariantId,
        'product': {'name': productName.toJson()},
        'quantity': quantity,
        'unit_price': unitPrice,
        'line_total': lineTotal,
        if (userId != null) 'user_id': userId,
        'user_name': userName,
        'vendor_id': vendorId,
        'vendor_name': vendorName,
      };

  static int _intFrom(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double _doubleFrom(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
