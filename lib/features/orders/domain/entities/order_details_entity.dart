import 'package:flutter/foundation.dart';
import 'order_entity.dart';
import 'order_geo_point.dart';
import 'delivery_tracking_entity.dart';
import 'order_item_entity.dart';
import 'order_refund_request_entity.dart';
import 'order_vendor_entity.dart';

@immutable
class OrderDetailsEntity {
  final String orderId;
  final OrderStatus status;
  final String etaText;
  final String destinationTitle;
  final String destinationAddress;
  final OrderGeoPoint? destinationLocation;
  final String pickupTitle;
  final String pickupAddress;
  final OrderGeoPoint? pickupLocation;
  final OrderGeoPoint? driverLocation;
  final DeliveryTrackingEntity? deliveryTracking;
  final String? deliveryCode;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final List<OrderVendorEntity> vendors;
  final int deliveryPartnerId;
  final String deliveryPartnerName;
  final String? deliveryPartnerPhone;
  final String? deliveryPartnerImage;
  final double deliveryPartnerRating;
  final String paymentMethod;
  final int ratingOutOf5;
  final bool? apiCanRequestRefund;
  final OrderRefundRequestEntity? refundRequest;
  final bool isSchedule;
  final DateTime? scheduledDeliveryAt;

  const OrderDetailsEntity({
    required this.orderId,
    required this.status,
    required this.etaText,
    required this.destinationTitle,
    required this.destinationAddress,
    this.destinationLocation,
    this.pickupTitle = '',
    this.pickupAddress = '',
    this.pickupLocation,
    this.driverLocation,
    this.deliveryTracking,
    required this.deliveryCode,
    required this.items,
    required this.totalAmount,
    this.vendors = const [],
    this.deliveryPartnerId = 0,
    this.deliveryPartnerName = '',
    this.deliveryPartnerPhone,
    this.deliveryPartnerImage,
    this.deliveryPartnerRating = 0,
    this.paymentMethod = 'cod',
    this.ratingOutOf5 = 0,
    this.apiCanRequestRefund,
    this.refundRequest,
    this.isSchedule = false,
    this.scheduledDeliveryAt,
  });

  List<OrderItemEntity> get productItems =>
      items.where((item) => !item.isCustomAddon).toList();

  List<OrderItemEntity> get addonItems =>
      items.where((item) => item.isCustomAddon).toList();

  List<OrderVendorEntity> get ratedVendors =>
      vendors.where((vendor) => vendor.isRated).toList();

  List<OrderVendorEntity> get unratedVendors =>
      vendors.where((vendor) => !vendor.isRated).toList();

  bool get hasUserRatings => ratedVendors.isNotEmpty;

  bool get hidesOrderActions =>
      status == OrderStatus.rejected ||
      status == OrderStatus.cancelled ||
      status == OrderStatus.refunded;

  /// Track map is available once the order is ready for pickup (or out for delivery).
  bool get canTrack => status == OrderStatus.outForDelivery;

  bool get canCancel =>
      status == OrderStatus.pending || status == OrderStatus.confirmed;

  bool get canReorder => status == OrderStatus.delivered;

  bool get canRate {
    if (status != OrderStatus.delivered) return false;
    if (vendors.isEmpty) return ratingOutOf5 <= 0;
    return unratedVendors.isNotEmpty;
  }

  /// Driven only by API `can_request_refund`.
  bool get canRequestRefund => apiCanRequestRefund == true;

  bool get isScheduledOrder => isSchedule || scheduledDeliveryAt != null;

  factory OrderDetailsEntity.fromJson(Map<String, dynamic> json) {
    final order = OrderEntity.fromJson(json);
    final minutes = json['estimated_delivery_time_minutes'];
    final etaText = minutes == null ? '' : '$minutes min';

    final deliveryAddressRaw = json['delivery_address'] ??
        json['customer_address'] ??
        json['address'];
    final deliveryZone = _asMap(json['delivery_zone']);
    final destinationTitle = deliveryZone?['name']?.toString() ??
        _stringFrom(deliveryAddressRaw, const [
          'title',
          'name',
          'zone',
          'district',
          'neighborhood',
        ]) ??
        '';
    final destinationAddress = _addressText(deliveryAddressRaw) ??
        json['delivery_address']?.toString() ??
        '';

    final vendorMap = _asMap(json['vendor']) ??
        _asMap(json['store']) ??
        _asMap(json['pickup']) ??
        _asMap(json['pickup_address']);
    final deliveryMap = _asMap(json['delivery_partner']) ??
        _asMap(json['deliveryPartner']) ??
        _asMap(json['courier']) ??
        _asMap(json['driver']) ??
        _asMap(json['rider']);

    final pickupTitle = _localizedName(
          vendorMap?['name'] ??
              vendorMap?['title'] ??
              json['vendor_name'] ??
              json['store_name'],
        ) ??
        order.vendorName;
    final pickupAddress = _addressText(vendorMap) ??
        _addressText(json['pickup_address']) ??
        '';

    final destinationLocation = OrderGeoPoint.tryParse(deliveryAddressRaw) ??
        OrderGeoPoint.tryParse(deliveryZone) ??
        OrderGeoPoint.tryParse(json['delivery_location']) ??
        OrderGeoPoint.tryParse(json['destination']) ??
        OrderGeoPoint.tryParse(json['destination_location']) ??
        OrderGeoPoint.tryParse(json['dropoff_location']) ??
        OrderGeoPoint.tryParse(json['customer_location']) ??
        OrderGeoPoint.tryParse({
          'latitude': json['delivery_latitude'] ??
              json['destination_latitude'] ??
              json['customer_latitude'] ??
              json['dropoff_latitude'],
          'longitude': json['delivery_longitude'] ??
              json['destination_longitude'] ??
              json['customer_longitude'] ??
              json['dropoff_longitude'],
        });

    final resolvedDestinationAddress = destinationAddress.trim().isNotEmpty &&
            !destinationAddress.trim().startsWith('{')
        ? destinationAddress.trim()
        : (_addressText(deliveryAddressRaw) ?? '');
    final resolvedDestinationTitle = destinationTitle.isNotEmpty
        ? destinationTitle
        : resolvedDestinationAddress;

    final pickupLocation = OrderGeoPoint.tryParse(vendorMap) ??
        OrderGeoPoint.tryParse(json['pickup_location']) ??
        OrderGeoPoint.tryParse(json['pickup']) ??
        OrderGeoPoint.tryParse(json['store_location']) ??
        OrderGeoPoint.tryParse(json['vendor_location']);

    final deliveryTracking = DeliveryTrackingEntity.tryParse(
          json['delivery_tracking'],
        ) ??
        DeliveryTrackingEntity.tryParse(json['deliveryTracking']);

    final driverLocation = OrderGeoPoint.tryParse(deliveryMap) ??
        OrderGeoPoint.tryParse(json['driver_location']) ??
        OrderGeoPoint.tryParse(json['delivery_partner_location']) ??
        OrderGeoPoint.tryParse(json['current_location']) ??
        OrderGeoPoint.tryParse(json['live_location']) ??
        OrderGeoPoint.tryParse(_asMap(json['delivery_tracking']));

    final partnerPhone = deliveryMap?['phone']?.toString() ??
        deliveryMap?['mobile']?.toString() ??
        json['delivery_partner_phone']?.toString();
    final partnerImage = deliveryMap?['image']?.toString() ??
        deliveryMap?['avatar']?.toString() ??
        deliveryMap?['image_url']?.toString() ??
        json['delivery_partner_image']?.toString();
    final partnerRating = _asDouble(
          deliveryMap?['rating'] ??
              deliveryMap?['average_rating'] ??
              deliveryMap?['rate'],
        ) ??
        0;

    return OrderDetailsEntity(
      orderId: order.id,
      status: order.status,
      etaText: etaText,
      destinationTitle: resolvedDestinationTitle,
      destinationAddress: resolvedDestinationAddress,
      destinationLocation: destinationLocation,
      pickupTitle: pickupTitle,
      pickupAddress: pickupAddress,
      pickupLocation: pickupLocation,
      driverLocation: driverLocation,
      deliveryTracking: deliveryTracking,
      deliveryCode: order.deliveryCode,
      items: order.items,
      totalAmount: order.totalPrice,
      vendors: order.vendors,
      deliveryPartnerId: order.deliveryPartnerId,
      deliveryPartnerName: order.deliveryPartnerName,
      deliveryPartnerPhone: partnerPhone,
      deliveryPartnerImage: partnerImage,
      deliveryPartnerRating: partnerRating,
      paymentMethod: order.paymentMethod,
      ratingOutOf5: order.ratingOutOf5,
      apiCanRequestRefund: order.apiCanRequestRefund,
      refundRequest: order.refundRequest,
      isSchedule: order.isSchedule,
      scheduledDeliveryAt: order.scheduledDeliveryAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': orderId,
        'status': status.name,
        'estimated_delivery_time_minutes': etaText,
        'delivery_zone': {'name': destinationTitle},
        'delivery_address': destinationAddress,
        'destination_location': destinationLocation?.toJson(),
        'pickup_title': pickupTitle,
        'pickup_address': pickupAddress,
        'pickup_location': pickupLocation?.toJson(),
        'driver_location': driverLocation?.toJson(),
        'delivery_tracking': deliveryTracking?.toJson(),
        'delivery_code': deliveryCode,
        'items': items.map((e) => e.toJson()).toList(),
        'total': totalAmount,
        'vendor_assignments': vendors.map((e) => e.toJson()).toList(),
        'delivery_partner_id': deliveryPartnerId,
        'delivery_partner_name': deliveryPartnerName,
        'delivery_partner_phone': deliveryPartnerPhone,
        'delivery_partner_image': deliveryPartnerImage,
        'delivery_partner_rating': deliveryPartnerRating,
        'payment_method': paymentMethod,
        'rating': ratingOutOf5,
        'can_request_refund': apiCanRequestRefund,
        'refund_request': refundRequest?.toJson(),
        'is_schedule': isSchedule,
        'scheduled_delivery_at': scheduledDeliveryAt?.toIso8601String(),
      };

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static String? _addressText(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      final text = raw.trim();
      return text.isEmpty ? null : text;
    }
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    for (final key in [
      'full_address',
      'address',
      'address_text',
      'formatted_address',
      'street',
      'line1',
    ]) {
      final value = map[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static String? _stringFrom(dynamic raw, List<String> keys) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    for (final key in keys) {
      final value = map[key];
      if (value == null) continue;
      if (value is Map) {
        final localized = _localizedName(value);
        if (localized != null && localized.isNotEmpty) return localized;
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  static String? _localizedName(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      final text = raw.trim();
      return text.isEmpty ? null : text;
    }
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    for (final key in ['ar', 'en', 'name', 'title', 'value']) {
      final text = map[key]?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  static double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
