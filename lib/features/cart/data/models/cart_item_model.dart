import '../../../products/data/models/product_model.dart';
import '../../../products/domain/entities/localized_name_entity.dart';
import '../../domain/entities/cart_addition_entity.dart';
import '../../domain/entities/cart_variant_entity.dart';
import '../../domain/entities/cart_vendor_ref_entity.dart';

class CartItemModel {
  final int id;
  final int vendorId;
  final int productId;
  final int? productVariantId;
  final bool isCustomAddon;
  final int quantity;
  final double baseUnitPrice;
  final double additionsUnitPrice;
  final double unitPrice;
  final double lineTotal;
  final List<CartAdditionEntity> additions;
  final ProductModel? product;
  final CartVariantEntity? variant;
  final LocalizedNameEntity addonName;
  final CartVendorRefEntity? vendor;
  final double originalUnitPrice;
  final double originalLineTotal;
  final double offerDiscount;
  final bool hasOffer;

  const CartItemModel({
    required this.id,
    required this.vendorId,
    required this.productId,
    this.productVariantId,
    required this.isCustomAddon,
    required this.quantity,
    required this.baseUnitPrice,
    required this.additionsUnitPrice,
    required this.unitPrice,
    required this.lineTotal,
    this.additions = const [],
    this.product,
    this.variant,
    this.addonName = const LocalizedNameEntity(ar: '', en: ''),
    this.vendor,
    required this.originalUnitPrice,
    required this.originalLineTotal,
    required this.offerDiscount,
    required this.hasOffer,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    double money(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    return CartItemModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      vendorId: json['vendor_id'] is int
          ? json['vendor_id'] as int
          : int.tryParse(json['vendor_id']?.toString() ?? '') ?? 0,
      productId: json['product_id'] is int
          ? json['product_id'] as int
          : int.tryParse(json['product_id']?.toString() ?? '') ?? 0,
      productVariantId: json['product_variant_id'] is int
          ? json['product_variant_id'] as int
          : int.tryParse(json['product_variant_id']?.toString() ?? ''),
      isCustomAddon: json['is_custom_addon'] == true,
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      baseUnitPrice: money(json['base_unit_price']),
      additionsUnitPrice: money(json['additions_unit_price']),
      unitPrice: money(json['unit_price']),
      lineTotal: money(json['line_total']),
      additions: (json['additions'] as List?)
              ?.whereType<Map>()
              .map(
                (e) => CartAdditionEntity.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
      product: json['product'] is Map
          ? ProductModel.fromJson(
              Map<String, dynamic>.from(json['product'] as Map),
            )
          : null,
      variant: json['variant'] is Map
          ? CartVariantEntity.fromJson(
              Map<String, dynamic>.from(json['variant'] as Map),
            )
          : null,
      addonName: LocalizedNameEntity.fromJson(
        json['addon_name'] is Map
            ? Map<String, dynamic>.from(json['addon_name'] as Map)
            : null,
      ),
      vendor: json['vendor'] is Map
          ? CartVendorRefEntity.fromJson(
              Map<String, dynamic>.from(json['vendor'] as Map),
            )
          : null,
      originalUnitPrice: money(json['original_unit_price']),
      originalLineTotal: money(json['original_line_total']),
      offerDiscount: money(json['offer_discount']),
      hasOffer: json['has_offer'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vendor_id': vendorId,
        'product_id': productId,
        'product_variant_id': productVariantId,
        'is_custom_addon': isCustomAddon,
        'quantity': quantity,
        'base_unit_price': baseUnitPrice,
        'additions_unit_price': additionsUnitPrice,
        'unit_price': unitPrice,
        'line_total': lineTotal,
        'additions': additions.map((e) => e.toJson()).toList(),
        if (product != null) 'product': product!.toJson(),
        'variant': variant?.toJson(),
        'addon_name': addonName.toJson(),
        if (vendor != null) 'vendor': vendor!.toJson(),
        'original_unit_price': originalUnitPrice,
        'original_line_total': originalLineTotal,
        'offer_discount': offerDiscount,
        'has_offer': hasOffer,
      };
}
