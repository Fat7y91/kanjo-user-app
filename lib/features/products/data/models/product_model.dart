import '../../domain/entities/localized_name_entity.dart';
import '../../domain/entities/product_addition_entity.dart';
import '../../domain/entities/product_category_ref_entity.dart';
import '../../domain/entities/product_gallery_item_entity.dart';
import '../../domain/entities/product_rating_summary_entity.dart';
import '../../domain/entities/product_variant_entity.dart';

class ProductModel {
  final int id;
  final int vendorId;
  final String slug;
  final String sku;
  final LocalizedNameEntity name;
  final LocalizedNameEntity description;
  final double price;
  final String displayPrice;
  final double discount;
  final String discountType;
  final String type;
  final String? thumbnailImageUrl;
  final int? preparationTimeMinutes;
  final bool isFeatured;
  final bool isNew;
  final int sortOrder;
  final bool isOutOfStock;
  final bool isOrderable;
  final ProductRatingSummaryEntity ratingSummary;
  final List<ProductCategoryRefEntity> categories;
  final List<ProductAdditionEntity> additions;
  final List<ProductVariantEntity> variants;
  final List<ProductGalleryItemEntity> gallery;

  const ProductModel({
    required this.id,
    required this.vendorId,
    required this.slug,
    required this.sku,
    required this.name,
    required this.description,
    required this.price,
    required this.displayPrice,
    required this.discount,
    required this.discountType,
    required this.type,
    this.thumbnailImageUrl,
    this.preparationTimeMinutes,
    required this.isFeatured,
    required this.isNew,
    required this.sortOrder,
    required this.isOutOfStock,
    required this.isOrderable,
    required this.ratingSummary,
    this.categories = const [],
    this.additions = const [],
    this.variants = const [],
    this.gallery = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final galleryItems = (json['gallery'] as List?)
            ?.whereType<Map>()
            .map((e) => ProductGalleryItemEntity.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList() ??
        <ProductGalleryItemEntity>[];
    galleryItems.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return ProductModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      vendorId: json['vendor_id'] is int
          ? json['vendor_id'] as int
          : int.tryParse(json['vendor_id']?.toString() ?? '') ?? 0,
      slug: json['slug']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      name: LocalizedNameEntity.fromJson(
        json['name'] is Map<String, dynamic>
            ? json['name'] as Map<String, dynamic>
            : null,
      ),
      description: LocalizedNameEntity.fromJson(
        json['description'] is Map<String, dynamic>
            ? json['description'] as Map<String, dynamic>
            : null,
      ),
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '') ?? 0,
      displayPrice: json['display_price']?.toString() ?? '',
      discount: json['discount'] is num
          ? (json['discount'] as num).toDouble()
          : double.tryParse(json['discount']?.toString() ?? '') ?? 0,
      discountType: json['discount_type']?.toString() ?? 'fixed',
      type: json['type']?.toString() ?? '',
      thumbnailImageUrl: json['thumbnail_image_url']?.toString(),
      preparationTimeMinutes: json['preparation_time_minutes'] is int
          ? json['preparation_time_minutes'] as int
          : int.tryParse(json['preparation_time_minutes']?.toString() ?? ''),
      isFeatured: json['is_featured'] == true,
      isNew: json['is_new'] == true,
      sortOrder: json['sort_order'] is int
          ? json['sort_order'] as int
          : int.tryParse(json['sort_order']?.toString() ?? '') ?? 0,
      isOutOfStock: json['is_out_of_stock'] == true,
      isOrderable: json['is_orderable'] != false,
      ratingSummary: ProductRatingSummaryEntity.fromJson(
        json['rating_summary'] is Map<String, dynamic>
            ? json['rating_summary'] as Map<String, dynamic>
            : null,
      ),
      categories: (json['categories'] as List?)
              ?.whereType<Map>()
              .map((e) => ProductCategoryRefEntity.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList() ??
          const [],
      additions: (json['additions'] as List?)
              ?.whereType<Map>()
              .map((e) => ProductAdditionEntity.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList() ??
          const [],
      variants: (json['variants'] as List?)
              ?.whereType<Map>()
              .map((e) => ProductVariantEntity.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList() ??
          const [],
      gallery: galleryItems,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vendor_id': vendorId,
        'slug': slug,
        'sku': sku,
        'name': name.toJson(),
        'description': description.toJson(),
        'price': price,
        'display_price': displayPrice,
        'discount': discount,
        'discount_type': discountType,
        'type': type,
        'thumbnail_image_url': thumbnailImageUrl,
        'preparation_time_minutes': preparationTimeMinutes,
        'is_featured': isFeatured,
        'is_new': isNew,
        'sort_order': sortOrder,
        'is_out_of_stock': isOutOfStock,
        'is_orderable': isOrderable,
        'rating_summary': ratingSummary.toJson(),
        'categories': categories.map((e) => e.toJson()).toList(),
        'additions': additions.map((e) => e.toJson()).toList(),
        'variants': variants.map((e) => e.toJson()).toList(),
        'gallery': gallery.map((e) => e.toJson()).toList(),
      };

  bool get hasDiscount => discount > 0;

  bool get isPercentDiscount {
    final t = discountType.toLowerCase().trim();
    return t == 'percent' || t == 'percentage';
  }

  /// Applies product discount to [base] (variant or product list price).
  double applyDiscount(double base) {
    if (!hasDiscount) return base;
    if (isPercentDiscount) {
      final value = base * (1 - (discount / 100));
      return value < 0 ? 0 : value;
    }
    final value = base - discount;
    return value < 0 ? 0 : value;
  }

  /// Reverses [applyDiscount] / offer percent to recover the pre-discount amount.
  double reverseDiscount(double discounted, {double? offerPercent}) {
    if (hasDiscount) {
      if (isPercentDiscount) {
        if (discount <= 0 || discount >= 100) return discounted;
        return discounted / (1 - (discount / 100));
      }
      return discounted + discount;
    }
    if (offerPercent != null && offerPercent > 0 && offerPercent < 100) {
      return discounted / (1 - (offerPercent / 100));
    }
    return discounted;
  }

  String? discountBadgeText() {
    if (!hasDiscount) return null;
    if (isPercentDiscount) {
      final value =
          discount % 1 == 0 ? discount.toInt().toString() : discount.toString();
      return '-$value%';
    }
    final value = discount % 1 == 0
        ? discount.toInt().toString()
        : discount.toStringAsFixed(2);
    return '-$value';
  }

  /// Pre-discount min–max, same basis as details (`variant.price`).
  ///
  /// List endpoints often omit variants and set `price` to 0 while putting the
  /// *already discounted* range in `display_price` — reverse that when needed.
  ({double min, double max}) originalListPriceRange({double? offerPercent}) {
    if (variants.isNotEmpty) {
      var minP = variants.first.price;
      var maxP = variants.first.price;
      for (final v in variants) {
        if (v.price < minP) minP = v.price;
        if (v.price > maxP) maxP = v.price;
      }
      return (min: minP, max: maxP);
    }

    final parsedDisplay = parseDisplayPriceRange(displayPrice);
    final hasOffer = offerPercent != null && offerPercent > 0;
    final needsReverse = hasDiscount || hasOffer;

    if (needsReverse) {
      if (parsedDisplay != null && price <= 0) {
        return (
          min: reverseDiscount(parsedDisplay.min, offerPercent: offerPercent),
          max: reverseDiscount(parsedDisplay.max, offerPercent: offerPercent),
        );
      }
      if (parsedDisplay != null && price > 0) {
        // Prefer reversing API discounted display (full range) over a single price.
        return (
          min: reverseDiscount(parsedDisplay.min, offerPercent: offerPercent),
          max: reverseDiscount(parsedDisplay.max, offerPercent: offerPercent),
        );
      }
      if (price > 0) return (min: price, max: price);
      return (min: 0, max: 0);
    }

    if (parsedDisplay != null) return parsedDisplay;
    return (min: price, max: price);
  }

  /// Parses API `display_price` values like `100-200`, `100 - 200`, or a single number.
  static ({double min, double max})? parseDisplayPriceRange(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;

    final match = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*(?:EGP|ج\.?\s*م\.?)?\s*[-–—]\s*(\d+(?:[.,]\d+)?)',
      caseSensitive: false,
    ).firstMatch(text);
    if (match != null) {
      final a = double.tryParse(match.group(1)!.replaceAll(',', ''));
      final b = double.tryParse(match.group(2)!.replaceAll(',', ''));
      if (a != null && b != null) {
        return a <= b ? (min: a, max: b) : (min: b, max: a);
      }
    }

    final singleMatch =
        RegExp(r'(\d+(?:[.,]\d+)?)').firstMatch(text.replaceAll(',', ''));
    if (singleMatch != null) {
      final single = double.tryParse(singleMatch.group(1)!);
      if (single != null) return (min: single, max: single);
    }
    return null;
  }
}
