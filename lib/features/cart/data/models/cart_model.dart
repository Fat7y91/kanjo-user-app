import '../../domain/entities/cart_rules_entity.dart';
import '../../domain/entities/cart_summary_entity.dart';
import '../../domain/entities/cart_wallet_entity.dart';
import 'cart_item_model.dart';

class CartModel {
  final List<CartItemModel> items;
  final CartSummaryEntity summary;
  final CartWalletEntity wallet;
  final int vendorCount;
  final CartRulesEntity cartRules;
  final bool hasBundleOrder;
  final int? bundleOrderId;
  final String? bundleOrderCode;

  const CartModel({
    required this.items,
    required this.summary,
    required this.wallet,
    required this.vendorCount,
    required this.cartRules,
    this.hasBundleOrder = false,
    this.bundleOrderId,
    this.bundleOrderCode,
  });

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  List<CartItemModel> get productItems =>
      items.where((item) => !item.isCustomAddon).toList();

  List<CartItemModel> get addonItems =>
      items.where((item) => item.isCustomAddon).toList();

  int? get singleVendorId {
    final ids = items.map((e) => e.vendorId).where((id) => id > 0).toSet();
    if (ids.length == 1) return ids.first;
    return null;
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      items: (json['items'] as List?)
              ?.whereType<Map>()
              .map(
                (e) => CartItemModel.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList() ??
          const [],
      summary: CartSummaryEntity.fromJson(
        json['summary'] is Map
            ? Map<String, dynamic>.from(json['summary'] as Map)
            : const <String, dynamic>{},
      ),
      wallet: CartWalletEntity.fromJson(
        json['wallet'] is Map
            ? Map<String, dynamic>.from(json['wallet'] as Map)
            : const <String, dynamic>{},
      ),
      vendorCount: json['vendor_count'] is int
          ? json['vendor_count'] as int
          : int.tryParse(json['vendor_count']?.toString() ?? '') ?? 0,
      cartRules: CartRulesEntity.fromJson(
        json['cart_rules'] is Map
            ? Map<String, dynamic>.from(json['cart_rules'] as Map)
            : const <String, dynamic>{},
      ),
      hasBundleOrder: json['has_bundle_order'] == true,
      bundleOrderId: json['bundle_order_id'] == null
          ? null
          : int.tryParse(json['bundle_order_id']?.toString() ?? ''),
      bundleOrderCode: json['bundle_order_code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
        'summary': summary.toJson(),
        'wallet': wallet.toJson(),
        'vendor_count': vendorCount,
        'cart_rules': cartRules.toJson(),
        'has_bundle_order': hasBundleOrder,
        'bundle_order_id': bundleOrderId,
        'bundle_order_code': bundleOrderCode,
      };
}
