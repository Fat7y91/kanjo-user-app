class LocationContextDeliveryZoneEntity {
  const LocationContextDeliveryZoneEntity({
    required this.id,
    required this.name,
    this.deliveryFee,
  });

  final int id;
  final String name;
  final double? deliveryFee;

  factory LocationContextDeliveryZoneEntity.fromJson(
    Map<String, dynamic>? json,
  ) {
    if (json == null) {
      return const LocationContextDeliveryZoneEntity(id: 0, name: '');
    }
    return LocationContextDeliveryZoneEntity(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      deliveryFee: _asDouble(json['delivery_fee']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'delivery_fee': deliveryFee,
      };
}

class LocationContextEntity {
  const LocationContextEntity({
    required this.mode,
    required this.isWithinDeliveryZone,
    required this.canPlaceOrder,
    this.deliveryZone,
    this.message,
  });

  final String mode;
  final bool isWithinDeliveryZone;
  final bool canPlaceOrder;
  final LocationContextDeliveryZoneEntity? deliveryZone;
  final String? message;

  factory LocationContextEntity.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const LocationContextEntity(
        mode: '',
        isWithinDeliveryZone: false,
        canPlaceOrder: false,
      );
    }
    final zoneRaw = json['delivery_zone'];
    return LocationContextEntity(
      mode: json['mode']?.toString() ?? '',
      isWithinDeliveryZone: json['is_within_delivery_zone'] == true,
      canPlaceOrder: json['can_place_order'] == true,
      deliveryZone: zoneRaw is Map
          ? LocationContextDeliveryZoneEntity.fromJson(
              Map<String, dynamic>.from(zoneRaw),
            )
          : null,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'mode': mode,
        'is_within_delivery_zone': isWithinDeliveryZone,
        'can_place_order': canPlaceOrder,
        'delivery_zone': deliveryZone?.toJson(),
        'message': message,
      };
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
