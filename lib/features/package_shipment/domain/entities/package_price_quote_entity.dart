class PackageRouteLegEntity {
  const PackageRouteLegEntity({
    required this.sequence,
    required this.fromLat,
    required this.fromLng,
    required this.toLat,
    required this.toLng,
    required this.distanceKm,
  });

  final int sequence;
  final double fromLat;
  final double fromLng;
  final double toLat;
  final double toLng;
  final double distanceKm;

  factory PackageRouteLegEntity.fromJson(Map<String, dynamic> json) {
    final from = json['from'] is Map
        ? Map<String, dynamic>.from(json['from'] as Map)
        : const <String, dynamic>{};
    final to = json['to'] is Map
        ? Map<String, dynamic>.from(json['to'] as Map)
        : const <String, dynamic>{};
    return PackageRouteLegEntity(
      sequence: _toInt(json['sequence']) ?? 0,
      fromLat: _toDouble(from['lat']) ?? 0,
      fromLng: _toDouble(from['lng']) ?? 0,
      toLat: _toDouble(to['lat']) ?? 0,
      toLng: _toDouble(to['lng']) ?? 0,
      distanceKm: _toDouble(json['distance_km']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'sequence': sequence,
        'from': {'lat': fromLat, 'lng': fromLng},
        'to': {'lat': toLat, 'lng': toLng},
        'distance_km': distanceKm,
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

class PackagePriceQuoteEntity {
  const PackagePriceQuoteEntity({
    required this.distanceKm,
    required this.pricePerKm,
    required this.calculatedBasePrice,
    required this.minimumDeliveryShipping,
    required this.minimumDeliveryShippingApplied,
    required this.basePrice,
    required this.sizeMultiplier,
    required this.totalPrice,
    required this.routeLegs,
    required this.dropoffsCount,
    this.pickupZoneId,
    this.dropoffZoneId,
    this.pricingType,
    this.zoneFixedPrice,
  });

  final double distanceKm;
  final double pricePerKm;
  final double calculatedBasePrice;
  final double minimumDeliveryShipping;
  final bool minimumDeliveryShippingApplied;
  final double basePrice;
  final double sizeMultiplier;
  final double totalPrice;
  final List<PackageRouteLegEntity> routeLegs;
  final int dropoffsCount;
  final int? pickupZoneId;
  final int? dropoffZoneId;
  final String? pricingType;
  final double? zoneFixedPrice;

  factory PackagePriceQuoteEntity.fromJson(Map<String, dynamic> json) {
    final legs = <PackageRouteLegEntity>[];
    final rawLegs = json['route_legs'];
    if (rawLegs is List) {
      for (final item in rawLegs) {
        if (item is Map) {
          legs.add(
            PackageRouteLegEntity.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return PackagePriceQuoteEntity(
      distanceKm: _toDouble(json['distance_km']) ?? 0,
      pricePerKm: _toDouble(json['price_per_km']) ?? 0,
      calculatedBasePrice: _toDouble(json['calculated_base_price']) ?? 0,
      minimumDeliveryShipping:
          _toDouble(json['minimum_delivery_shipping']) ?? 0,
      minimumDeliveryShippingApplied:
          json['minimum_delivery_shipping_applied'] == true,
      basePrice: _toDouble(json['base_price']) ?? 0,
      sizeMultiplier: _toDouble(json['size_multiplier']) ?? 1,
      totalPrice: _toDouble(json['total_price']) ?? 0,
      routeLegs: legs,
      dropoffsCount: _toInt(json['dropoffs_count']) ?? legs.length,
      pickupZoneId: _toInt(json['pickup_zone_id']),
      dropoffZoneId: _toInt(json['dropoff_zone_id']),
      pricingType: json['pricing_type']?.toString(),
      zoneFixedPrice: _toDouble(json['zone_fixed_price']),
    );
  }

  Map<String, dynamic> toJson() => {
        'distance_km': distanceKm,
        'price_per_km': pricePerKm,
        'calculated_base_price': calculatedBasePrice,
        'minimum_delivery_shipping': minimumDeliveryShipping,
        'minimum_delivery_shipping_applied': minimumDeliveryShippingApplied,
        'base_price': basePrice,
        'size_multiplier': sizeMultiplier,
        'total_price': totalPrice,
        'route_legs': routeLegs.map((e) => e.toJson()).toList(),
        'dropoffs_count': dropoffsCount,
        'pickup_zone_id': pickupZoneId,
        'dropoff_zone_id': dropoffZoneId,
        'pricing_type': pricingType,
        'zone_fixed_price': zoneFixedPrice,
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
