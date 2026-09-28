import 'package:get/get.dart';

import '../entities/package_dropoff_entity.dart';
import '../entities/package_size_entity.dart';

class PackageShipmentEntity {
  const PackageShipmentEntity({
    required this.id,
    required this.senderId,
    required this.packageSizeId,
    this.packageSize,
    this.packageImage,
    this.packageImageUrl,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    this.pickupZoneId,
    required this.dropoffAddress,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.receiverName,
    required this.receiverPhone,
    required this.distanceKm,
    this.zonePricingType,
    this.zoneFixedPrice,
    this.zoneMinShipping,
    this.pricePerKm,
    required this.basePrice,
    required this.totalPrice,
    this.finalPrice,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.dropoffs,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int senderId;
  final int packageSizeId;
  final PackageSizeEntity? packageSize;
  final String? packageImage;
  final String? packageImageUrl;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final int? pickupZoneId;
  final String dropoffAddress;
  final double dropoffLat;
  final double dropoffLng;
  final String receiverName;
  final String receiverPhone;
  final double distanceKm;
  final String? zonePricingType;
  final double? zoneFixedPrice;
  final double? zoneMinShipping;
  final double? pricePerKm;
  final double basePrice;
  final double totalPrice;
  final double? finalPrice;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final List<PackageDropoffEntity> dropoffs;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get canCancel =>
      status == 'pending' || status == 'confirmed';

  double get displayPrice => finalPrice ?? totalPrice;

  factory PackageShipmentEntity.fromJson(Map<String, dynamic> json) {
    PackageSizeEntity? size;
    final rawSize = json['package_size'];
    if (rawSize is Map) {
      size = PackageSizeEntity.fromJson(Map<String, dynamic>.from(rawSize));
    }

    final dropoffs = <PackageDropoffEntity>[];
    final rawDropoffs = json['dropoffs'];
    if (rawDropoffs is List) {
      for (final item in rawDropoffs) {
        if (item is Map) {
          dropoffs.add(
            PackageDropoffEntity.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return PackageShipmentEntity(
      id: _toInt(json['id']) ?? 0,
      senderId: _toInt(json['sender_id']) ?? 0,
      packageSizeId: _toInt(json['package_size_id']) ?? size?.id ?? 0,
      packageSize: size,
      packageImage: json['package_image']?.toString(),
      packageImageUrl: json['package_image_url']?.toString(),
      pickupAddress: json['pickup_address']?.toString() ?? '',
      pickupLat: _toDouble(json['pickup_lat']) ?? 0,
      pickupLng: _toDouble(json['pickup_lng']) ?? 0,
      pickupZoneId: _toInt(json['pickup_zone_id']),
      dropoffAddress: json['dropoff_address']?.toString() ?? '',
      dropoffLat: _toDouble(json['dropoff_lat']) ?? 0,
      dropoffLng: _toDouble(json['dropoff_lng']) ?? 0,
      receiverName: json['receiver_name']?.toString() ?? '',
      receiverPhone: json['receiver_phone']?.toString() ?? '',
      distanceKm: _toDouble(json['distance_km']) ?? 0,
      zonePricingType: json['zone_pricing_type']?.toString(),
      zoneFixedPrice: _toDouble(json['zone_fixed_price']),
      zoneMinShipping: _toDouble(json['zone_min_shipping']),
      pricePerKm: _toDouble(json['price_per_km']),
      basePrice: _toDouble(json['base_price']) ?? 0,
      totalPrice: _toDouble(json['total_price']) ?? 0,
      finalPrice: _toDouble(json['final_price']),
      status: json['status']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      dropoffs: dropoffs,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender_id': senderId,
        'package_size_id': packageSizeId,
        'package_size': packageSize?.toJson(),
        'package_image': packageImage,
        'package_image_url': packageImageUrl,
        'pickup_address': pickupAddress,
        'pickup_lat': pickupLat,
        'pickup_lng': pickupLng,
        'pickup_zone_id': pickupZoneId,
        'dropoff_address': dropoffAddress,
        'dropoff_lat': dropoffLat,
        'dropoff_lng': dropoffLng,
        'receiver_name': receiverName,
        'receiver_phone': receiverPhone,
        'distance_km': distanceKm,
        'zone_pricing_type': zonePricingType,
        'zone_fixed_price': zoneFixedPrice,
        'zone_min_shipping': zoneMinShipping,
        'price_per_km': pricePerKm,
        'base_price': basePrice,
        'total_price': totalPrice,
        'final_price': finalPrice,
        'status': status,
        'payment_status': paymentStatus,
        'payment_method': paymentMethod,
        'dropoffs': dropoffs.map((e) => e.toJson()).toList(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

String packageShipmentStatusLabel(String? status) {
  switch (status?.toLowerCase().trim()) {
    case 'pending':
      return 'Pending'.tr;
    case 'confirmed':
    case 'accepted':
      return 'Confirmed'.tr;
    case 'assigned':
      return 'Assigned'.tr;
    case 'picked_up':
    case 'picked-up':
      return 'Picked up'.tr;
    case 'in_transit':
    case 'in-transit':
    case 'on_the_way':
    case 'on-the-way':
      return 'In transit'.tr;
    case 'out_for_delivery':
    case 'out-for-delivery':
      return 'Out for delivery'.tr;
    case 'processing':
      return 'Processing'.tr;
    case 'delivered':
    case 'completed':
      return 'Delivered'.tr;
    case 'cancelled':
    case 'canceled':
      return 'Cancelled'.tr;
    case 'rejected':
      return 'Rejected'.tr;
    case 'failed':
      return 'Failed'.tr;
    default:
      final raw = status?.trim() ?? '';
      if (raw.isEmpty) return '-';
      final key = raw
          .split(RegExp(r'[_\-\s]+'))
          .where((part) => part.isNotEmpty)
          .map(
            (part) =>
                '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
          )
          .join(' ');
      return key.tr;
  }
}

String packageShipmentPaymentStatusLabel(String? status) {
  switch (status?.toLowerCase().trim()) {
    case 'paid':
      return 'Paid'.tr;
    case 'unpaid':
      return 'Unpaid'.tr;
    case 'pending':
      return 'Pending'.tr;
    case 'refunded':
      return 'Refunded'.tr;
    case 'failed':
      return 'Failed'.tr;
    default:
      return packageShipmentStatusLabel(status);
  }
}
