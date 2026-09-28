import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../products/domain/entities/localized_name_entity.dart';
import 'order_item_entity.dart';
import 'order_user_rating_entity.dart';

@immutable
class OrderVendorEntity {
  final int id;
  final String name;
  final OrderUserRatingEntity? userRating;

  const OrderVendorEntity({
    required this.id,
    required this.name,
    this.userRating,
  });

  bool get isRated => userRating != null;

  factory OrderVendorEntity.fromJson(Map<String, dynamic> json) {
    final vendorMap = json['vendor'] is Map
        ? Map<String, dynamic>.from(json['vendor'] as Map)
        : null;
    final ratingRaw = vendorMap?['user_rating'] ?? json['user_rating'];
    return OrderVendorEntity(
      id: _id(json['vendor_id'] ?? json['id'] ?? vendorMap?['id']),
      name: _localizedName(
        vendorMap?['name'] ?? json['vendor_name'] ?? json['name'],
      ),
      userRating: ratingRaw is Map
          ? OrderUserRatingEntity.fromJson(
              Map<String, dynamic>.from(ratingRaw),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'vendor_id': id,
        'vendor_name': name,
        'user_rating': userRating?.toJson(),
      };

  OrderVendorEntity copyWith({
    int? id,
    String? name,
    OrderUserRatingEntity? userRating,
    bool clearUserRating = false,
  }) {
    return OrderVendorEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      userRating: clearUserRating ? null : (userRating ?? this.userRating),
    );
  }
}

/// Builds the vendor rating sequence from order items' `vendor_id`,
/// enriching names / ratings from `vendor_assignments` / nested `vendor`.
List<OrderVendorEntity> parseOrderVendors({
  required Map<String, dynamic> json,
  required List<OrderItemEntity> items,
}) {
  final byId = <int, OrderVendorEntity>{};

  void merge(OrderVendorEntity vendor) {
    if (vendor.id <= 0) return;
    final existing = byId[vendor.id];
    if (existing == null) {
      byId[vendor.id] = vendor;
      return;
    }
    byId[vendor.id] = existing.copyWith(
      name: vendor.name.trim().isNotEmpty ? vendor.name : existing.name,
      userRating: vendor.userRating ?? existing.userRating,
    );
  }

  final assignmentsRaw =
      json['vendor_assignments'] ?? json['vendor_orders'] ?? json['vendors'];
  if (assignmentsRaw is List) {
    for (final raw in assignmentsRaw) {
      if (raw is! Map) continue;
      merge(OrderVendorEntity.fromJson(Map<String, dynamic>.from(raw)));
    }
  }

  final rootVendor = json['vendor'];
  if (rootVendor is Map) {
    merge(OrderVendorEntity.fromJson(Map<String, dynamic>.from(rootVendor)));
  }

  merge(
    OrderVendorEntity(
      id: _id(json['vendor_id']),
      name: _localizedName(json['vendor_name']),
    ),
  );

  for (final item in items) {
    merge(
      OrderVendorEntity(
        id: item.vendorId,
        name: item.vendorName,
      ),
    );
  }

  final seen = <int>{};
  final result = <OrderVendorEntity>[];

  void add(int id) {
    if (id <= 0 || !seen.add(id)) return;
    result.add(
      byId[id] ??
          OrderVendorEntity(
            id: id,
            name: '',
          ),
    );
  }

  for (final item in items) {
    add(item.vendorId);
  }
  for (final id in byId.keys) {
    add(id);
  }

  return result;
}

int _id(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _localizedName(dynamic value) {
  if (value == null) return '';
  if (value is String) return value.trim();
  if (value is Map) {
    return LocalizedNameEntity.fromJson(Map<String, dynamic>.from(value))
        .localized(Get.locale?.languageCode);
  }
  return value.toString().trim();
}
