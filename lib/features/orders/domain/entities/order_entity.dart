import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../products/domain/entities/localized_name_entity.dart';
import 'order_item_entity.dart';
import 'order_refund_request_entity.dart';
import 'order_vendor_entity.dart';

enum OrderStatus {
  pending,
  confirmed,
  rejected,
  cancelled,
  processing,
  readyForPickup,
  outForDelivery,
  delivered,
  refunded,
}

@immutable
class OrderEntity {
  final String id;
  final DateTime createdAt;
  final OrderStatus status;
  final double totalPrice;
  final int ratingOutOf5;
  final List<OrderItemEntity> items;
  final String? deliveryCode;
  final int vendorId;
  final String vendorName;
  final int deliveryPartnerId;
  final String deliveryPartnerName;
  final String paymentMethod;
  final List<OrderVendorEntity> assignedVendors;
  final bool? apiCanRequestRefund;
  final OrderRefundRequestEntity? refundRequest;
  final bool isSchedule;
  final DateTime? scheduledDeliveryAt;

  const OrderEntity({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.totalPrice,
    required this.ratingOutOf5,
    required this.items,
    this.deliveryCode,
    this.vendorId = 0,
    this.vendorName = '',
    this.deliveryPartnerId = 0,
    this.deliveryPartnerName = '',
    this.paymentMethod = 'cod',
    this.assignedVendors = const [],
    this.apiCanRequestRefund,
    this.refundRequest,
    this.isSchedule = false,
    this.scheduledDeliveryAt,
  });

  int get itemsCount => productItems.length;

  List<OrderItemEntity> get productItems =>
      items.where((item) => !item.isCustomAddon).toList();

  List<OrderItemEntity> get addonItems =>
      items.where((item) => item.isCustomAddon).toList();

  List<OrderVendorEntity> get vendors {
    if (assignedVendors.isNotEmpty) return assignedVendors;
    return parseOrderVendors(
      json: {
        'vendor_id': vendorId,
        'vendor_name': vendorName,
      },
      items: items,
    );
  }

  List<OrderVendorEntity> get ratedVendors =>
      vendors.where((vendor) => vendor.isRated).toList();

  List<OrderVendorEntity> get unratedVendors =>
      vendors.where((vendor) => !vendor.isRated).toList();

  bool get hasUserRatings => ratedVendors.isNotEmpty;

  /// Delivered orders that still have at least one unrated vendor.
  /// If vendors are unknown, fall back to root rating absence.
  bool get canRate {
    if (status != OrderStatus.delivered) return false;
    if (vendors.isEmpty) return ratingOutOf5 <= 0;
    return unratedVendors.isNotEmpty;
  }

  bool get canReorder => status == OrderStatus.delivered;

  bool get isCashOnDelivery => paymentMethod.trim().toLowerCase() == 'cod';

  /// Driven only by API `can_request_refund`.
  bool get canRequestRefund => apiCanRequestRefund == true;

  /// Rejected / cancelled / refunded orders have no track/reorder actions.
  bool get hidesOrderActions =>
      status == OrderStatus.rejected ||
      status == OrderStatus.cancelled ||
      status == OrderStatus.refunded;

  /// Track map is available once the order is ready for pickup (or out for delivery).
  bool get canTrack => status == OrderStatus.outForDelivery;

  /// In-progress order that can still be tracked.
  bool get isActive =>
      status == OrderStatus.pending ||
      status == OrderStatus.confirmed ||
      status == OrderStatus.processing ||
      status == OrderStatus.readyForPickup ||
      status == OrderStatus.outForDelivery;

  bool get isScheduledOrder => isSchedule || scheduledDeliveryAt != null;

  OrderEntity copyWith({
    String? id,
    DateTime? createdAt,
    OrderStatus? status,
    double? totalPrice,
    int? ratingOutOf5,
    List<OrderItemEntity>? items,
    String? deliveryCode,
    int? vendorId,
    String? vendorName,
    int? deliveryPartnerId,
    String? deliveryPartnerName,
    String? paymentMethod,
    List<OrderVendorEntity>? assignedVendors,
    bool? apiCanRequestRefund,
    OrderRefundRequestEntity? refundRequest,
    bool clearRefundRequest = false,
    bool? isSchedule,
    DateTime? scheduledDeliveryAt,
    bool clearScheduledDeliveryAt = false,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      ratingOutOf5: ratingOutOf5 ?? this.ratingOutOf5,
      items: items ?? this.items,
      deliveryCode: deliveryCode ?? this.deliveryCode,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      deliveryPartnerId: deliveryPartnerId ?? this.deliveryPartnerId,
      deliveryPartnerName: deliveryPartnerName ?? this.deliveryPartnerName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      assignedVendors: assignedVendors ?? this.assignedVendors,
      apiCanRequestRefund: apiCanRequestRefund ?? this.apiCanRequestRefund,
      refundRequest:
          clearRefundRequest ? null : (refundRequest ?? this.refundRequest),
      isSchedule: isSchedule ?? this.isSchedule,
      scheduledDeliveryAt: clearScheduledDeliveryAt
          ? null
          : (scheduledDeliveryAt ?? this.scheduledDeliveryAt),
    );
  }

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List?)
            ?.whereType<Map>()
            .map((e) => OrderItemEntity.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        const <OrderItemEntity>[];

    Map<String, dynamic>? firstItem;
    final rawItems = json['items'];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          firstItem = Map<String, dynamic>.from(item);
          break;
        }
      }
    }

    final vendorMap = _asMap(json['vendor']) ??
        _asMap(json['store']) ??
        _asMap(firstItem?['vendor']);
    final deliveryMap = _asMap(json['delivery_partner']) ??
        _asMap(json['deliveryPartner']) ??
        _asMap(json['courier']) ??
        _asMap(json['driver']) ??
        _asMap(json['rider']);

    final assignedVendors = parseOrderVendors(json: json, items: items);
    final rootRating = json['rating'] is int
        ? json['rating'] as int
        : int.tryParse(json['rating']?.toString() ?? '') ?? 0;
    final averageVendorRating = _averageVendorRating(assignedVendors);

    final refundRaw = json['refund_request'];
    final scheduledAt = parseOrderScheduledDeliveryAt(
      json['scheduled_delivery_at'],
    );
    final isSchedule = json['is_schedule'] == true ||
        json['is_schedule']?.toString() == '1' ||
        json['is_schedule']?.toString().toLowerCase() == 'true' ||
        scheduledAt != null;

    return OrderEntity(
      id: json['id']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      status: orderStatusFromApi(json['status']?.toString()),
      totalPrice:
          _money(json['total'] ?? json['amount_due'] ?? json['total_price']),
      ratingOutOf5: rootRating > 0 ? rootRating : averageVendorRating,
      items: items,
      deliveryCode: json['delivery_code']?.toString(),
      vendorId: _id(
        json['vendor_id'] ??
            vendorMap?['id'] ??
            firstItem?['vendor_id'] ??
            json['store_id'],
      ),
      vendorName: _localizedName(vendorMap?['name'] ?? json['vendor_name']),
      deliveryPartnerId: _id(
        json['delivery_partner_id'] ??
            json['deliveryPartnerId'] ??
            deliveryMap?['id'] ??
            json['courier_id'] ??
            json['driver_id'],
      ),
      deliveryPartnerName: _localizedName(
        deliveryMap?['name'] ??
            deliveryMap?['full_name'] ??
            json['delivery_partner_name'],
      ),
      paymentMethod: json['payment_method']?.toString() ?? 'cod',
      assignedVendors: assignedVendors,
      apiCanRequestRefund: json['can_request_refund'] is bool
          ? json['can_request_refund'] as bool
          : null,
      refundRequest: refundRaw is Map
          ? OrderRefundRequestEntity.fromJson(
              Map<String, dynamic>.from(refundRaw),
            )
          : null,
      isSchedule: isSchedule,
      scheduledDeliveryAt: scheduledAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'status': status.name,
        'total': totalPrice,
        'rating': ratingOutOf5,
        'items': items.map((e) => e.toJson()).toList(),
        'delivery_code': deliveryCode,
        'vendor_id': vendorId,
        'vendor_name': vendorName,
        'delivery_partner_id': deliveryPartnerId,
        'delivery_partner_name': deliveryPartnerName,
        'payment_method': paymentMethod,
        'vendor_assignments': assignedVendors.map((e) => e.toJson()).toList(),
        'can_request_refund': apiCanRequestRefund,
        'refund_request': refundRequest?.toJson(),
        'is_schedule': isSchedule,
        'scheduled_delivery_at': scheduledDeliveryAt?.toIso8601String(),
      };
}

int _averageVendorRating(List<OrderVendorEntity> vendors) {
  final ratings = vendors
      .map((vendor) => vendor.userRating?.ratingOutOf5)
      .whereType<int>()
      .where((rating) => rating > 0)
      .toList();
  if (ratings.isEmpty) return 0;
  final sum = ratings.fold<int>(0, (total, rating) => total + rating);
  return (sum / ratings.length).round().clamp(1, 5);
}

OrderStatus orderStatusFromApi(String? status) {
  switch (status?.toLowerCase().trim()) {
    case 'pending':
      return OrderStatus.pending;
    case 'confirmed':
    case 'accepted':
      return OrderStatus.confirmed;
    case 'rejected':
      return OrderStatus.rejected;
    case 'cancelled':
    case 'canceled':
      return OrderStatus.cancelled;
    case 'processing':
    case 'preparing':
      return OrderStatus.processing;
    case 'ready_for_pickup':
    case 'ready-for-pickup':
      return OrderStatus.readyForPickup;
    case 'out_for_delivery':
    case 'out-for-delivery':
    case 'on_the_way':
      return OrderStatus.outForDelivery;
    case 'delivered':
    case 'completed':
      return OrderStatus.delivered;
    case 'refunded':
      return OrderStatus.refunded;
    default:
      return OrderStatus.pending;
  }
}

String orderStatusLabel(OrderStatus status) {
  return switch (status) {
    OrderStatus.pending => 'Pending'.tr,
    OrderStatus.confirmed => 'Confirmed'.tr,
    OrderStatus.rejected => 'Rejected'.tr,
    OrderStatus.cancelled => 'Cancelled'.tr,
    OrderStatus.processing => 'Processing'.tr,
    OrderStatus.readyForPickup => 'Ready for pickup'.tr,
    OrderStatus.outForDelivery => 'Out for delivery'.tr,
    OrderStatus.delivered => 'Delivered'.tr,
    OrderStatus.refunded => 'Refunded'.tr,
  };
}

/// Happy-path tracking steps shown in the order details stepper.
List<OrderStatus> get orderTrackingSteps => const [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.processing,
      OrderStatus.readyForPickup,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];

int orderTrackingStepIndex(OrderStatus status) {
  final index = orderTrackingSteps.indexOf(status);
  if (index >= 0) return index;
  // Terminal / failed statuses: keep progress before delivery.
  return switch (status) {
    OrderStatus.rejected || OrderStatus.cancelled => 1,
    OrderStatus.refunded => orderTrackingSteps.length - 1,
    _ => 0,
  };
}

double _money(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? parseOrderScheduledDeliveryAt(dynamic value) {
  final raw = value?.toString().trim() ?? '';
  if (raw.isEmpty || raw.toLowerCase() == 'null') return null;

  final parsed =
      DateTime.tryParse(raw) ?? DateTime.tryParse(raw.replaceFirst(' ', 'T'));
  if (parsed != null) return parsed;

  for (final pattern in const [
    'yyyy-MM-dd HH:mm:ss',
    'yyyy-MM-dd HH:mm',
  ]) {
    try {
      return DateFormat(pattern).parse(raw);
    } catch (_) {}
  }
  return null;
}

String formatOrderScheduledDeliveryAt(
  DateTime value, {
  String? locale,
}) {
  return DateFormat('EEE, d MMM • h:mm a', locale).format(value);
}

int _id(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
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
