import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../products/domain/entities/localized_name_entity.dart';
import '../../../../config/app_assets.dart';
import 'order_addition_entity.dart';

@immutable
class OrderItemEntity {
  final String id;
  final String sku;
  final int? productId;
  final String name;
  final String imagePath;
  final String? imageUrl;
  final double price;
  final int quantity;
  final bool isCustomAddon;
  final LocalizedNameEntity addonName;
  final LocalizedNameEntity variantName;
  final List<OrderAdditionEntity> additions;
  final int vendorId;
  final String vendorName;

  const OrderItemEntity({
    required this.id,
    this.sku = '',
    this.productId,
    required this.name,
    required this.imagePath,
    this.imageUrl,
    required this.price,
    this.quantity = 1,
    this.isCustomAddon = false,
    this.addonName = const LocalizedNameEntity(ar: '', en: ''),
    this.variantName = const LocalizedNameEntity(ar: '', en: ''),
    this.additions = const [],
    this.vendorId = 0,
    this.vendorName = '',
  });

  bool get isPharmacyAddon => isCustomAddon;

  String displayName([String? languageCode]) {
    if (!isCustomAddon) return name;
    final addonTitle = addonName.localized(languageCode);
    if (addonTitle.isNotEmpty) return addonTitle;
    if (name.isNotEmpty) return name;
    return 'Pharmacy addon'.tr;
  }

  String addonSubtitle() {
    final vendor = vendorName.trim();
    if (vendor.isNotEmpty) {
      return 'Addon from @vendor'.trParams({'vendor': vendor});
    }
    return 'Pharmacy addon'.tr;
  }

  String variantLabel([String? languageCode]) {
    return variantName.localized(languageCode).trim();
  }

  String additionsLabel([String? languageCode]) {
    return additions
        .map((e) => e.name.localized(languageCode).trim())
        .where((e) => e.isNotEmpty)
        .join(', ');
  }

  factory OrderItemEntity.fromJson(Map<String, dynamic> json) {
    final languageCode = Get.locale?.languageCode ?? 'en';
    final sku = json['sku']?.toString() ?? '';
    final productId = _nullableId(json['product_id']);
    final isCustomAddon = json['is_custom_addon'] == true ||
        sku.toUpperCase() == 'PHARMACY-ADDON' ||
        productId == null;
    final addonName = LocalizedNameEntity.fromJson(
      json['addon_name'] is Map
          ? Map<String, dynamic>.from(json['addon_name'] as Map)
          : json['product_name'] is Map && isCustomAddon
              ? Map<String, dynamic>.from(json['product_name'] as Map)
              : null,
    );
    final vendorMap = json['vendor'] is Map
        ? Map<String, dynamic>.from(json['vendor'] as Map)
        : null;
    final vendorName = _localizedName(
      vendorMap?['name'] ?? json['vendor_name'],
      languageCode,
    );
    final vendorId = _nullableId(json['vendor_id'] ?? vendorMap?['id']) ?? 0;

    final productName = LocalizedNameEntity.fromJson(
      json['product_name'] is Map
          ? Map<String, dynamic>.from(json['product_name'] as Map)
          : json['product'] is Map && (json['product'] as Map)['name'] is Map
              ? Map<String, dynamic>.from(
                  (json['product'] as Map)['name'] as Map,
                )
              : null,
    );
    final variantName = json['variant'] is Map
        ? LocalizedNameEntity.fromJson(
            (json['variant'] as Map)['name'] is Map
                ? Map<String, dynamic>.from(
                    (json['variant'] as Map)['name'] as Map,
                  )
                : null,
          )
        : const LocalizedNameEntity(ar: '', en: '');

    final addonTitle = addonName.localized(languageCode);
    final baseName = productName.localized(languageCode);
    final displayName = isCustomAddon
        ? (addonTitle.isNotEmpty
            ? addonTitle
            : (baseName.isNotEmpty
                ? baseName
                : (json['name']?.toString() ?? sku)))
        : (baseName.isNotEmpty
            ? baseName
            : (json['name']?.toString() ?? sku));

    return OrderItemEntity(
      id: json['id']?.toString() ?? '',
      sku: sku,
      productId: productId,
      name: displayName,
      imagePath: AppAssets.homeCategoryFood,
      imageUrl: _imageUrlFromJson(json),
      price: _money(json['line_total'] ?? json['unit_price'] ?? json['price']),
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse(json['quantity']?.toString() ?? '') ?? 1,
      isCustomAddon: isCustomAddon,
      addonName: addonName,
      variantName: variantName,
      additions: (json['additions'] as List?)
              ?.whereType<Map>()
              .map(
                (e) => OrderAdditionEntity.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
      vendorId: vendorId,
      vendorName: vendorName,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sku': sku,
        'product_id': productId,
        'name': name,
        'image_path': imagePath,
        'image_url': imageUrl,
        'price': price,
        'quantity': quantity,
        'is_custom_addon': isCustomAddon,
        'addon_name': addonName.toJson(),
        'variant_name': variantName.toJson(),
        'additions': additions.map((e) => e.toJson()).toList(),
        'vendor_id': vendorId,
        'vendor_name': vendorName,
      };
}

double _money(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int? _nullableId(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

String _localizedName(dynamic value, String languageCode) {
  if (value == null) return '';
  if (value is String) return value.trim();
  if (value is Map) {
    return LocalizedNameEntity.fromJson(Map<String, dynamic>.from(value))
        .localized(languageCode);
  }
  return value.toString().trim();
}

String? _imageUrlFromJson(Map<String, dynamic> json) {
  final direct = json['image_url']?.toString().trim();
  if (direct != null && direct.isNotEmpty) return direct;

  if (json['variant'] is Map) {
    final variantImage =
        (json['variant'] as Map)['image_url']?.toString().trim();
    if (variantImage != null && variantImage.isNotEmpty) return variantImage;
  }

  if (json['product'] is Map) {
    final product = json['product'] as Map;
    final thumbnail = product['thumbnail_image_url']?.toString().trim();
    if (thumbnail != null && thumbnail.isNotEmpty) return thumbnail;
    final image = product['image_url']?.toString().trim();
    if (image != null && image.isNotEmpty) return image;
  }
  return null;
}
