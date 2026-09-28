import 'package:flutter/foundation.dart';
import 'package:heraj/features/orders/domain/entities/order_geo_point.dart';

/// Live payload from `delivery.partner.location.updated`.
@immutable
class DeliveryPartnerLiveUpdate {
  const DeliveryPartnerLiveUpdate({
    required this.latitude,
    required this.longitude,
    this.partnerId,
    this.displayName,
    this.zoneId,
    this.availabilityStatus,
    this.updatedAt,
    this.activeOrderId,
    this.activePackageShipmentId,
  });

  final double latitude;
  final double longitude;
  final int? partnerId;
  final String? displayName;
  final int? zoneId;
  final String? availabilityStatus;
  final String? updatedAt;
  final String? activeOrderId;
  final String? activePackageShipmentId;

  OrderGeoPoint get location => OrderGeoPoint(
        latitude: latitude,
        longitude: longitude,
      );

  Map<String, dynamic> toJson() => {
        'partner_id': partnerId,
        'display_name': displayName,
        'latitude': latitude,
        'longitude': longitude,
        'zone_id': zoneId,
        'availability_status': availabilityStatus,
        'updated_at': updatedAt,
        'active_order_id': activeOrderId,
        'active_package_shipment_id': activePackageShipmentId,
      };

  static DeliveryPartnerLiveUpdate? tryParse(
    Map<String, dynamic> data, {
    String? expectedOrderId,
  }) {
    final activeOrderId = data['active_order_id']?.toString() ??
        data['order_id']?.toString() ??
        data['orderId']?.toString();
    if (expectedOrderId != null &&
        expectedOrderId.isNotEmpty &&
        activeOrderId != null &&
        activeOrderId.isNotEmpty &&
        activeOrderId != expectedOrderId) {
      return null;
    }

    final point = OrderGeoPoint.tryParse(data);
    if (point == null) return null;

    return DeliveryPartnerLiveUpdate(
      latitude: point.latitude,
      longitude: point.longitude,
      partnerId: _asInt(data['partner_id'] ?? data['delivery_partner_id']),
      displayName: _asString(
        data['display_name'] ?? data['name'] ?? data['partner_name'],
      ),
      zoneId: _asInt(data['zone_id']),
      availabilityStatus: _asString(data['availability_status']),
      updatedAt: _asString(data['updated_at']),
      activeOrderId: activeOrderId,
      activePackageShipmentId:
          _asString(data['active_package_shipment_id']),
    );
  }

  static DeliveryPartnerLiveUpdate? fromGeoPoint(OrderGeoPoint? point) {
    if (point == null) return null;
    return DeliveryPartnerLiveUpdate(
      latitude: point.latitude,
      longitude: point.longitude,
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static String? _asString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return null;
    return text;
  }
}
