class DeliveryZoneEntity {
  const DeliveryZoneEntity({
    required this.id,
    required this.name,
    required this.centerLatitude,
    required this.centerLongitude,
  });

  final int id;
  final String name;
  final double centerLatitude;
  final double centerLongitude;

  factory DeliveryZoneEntity.fromJson(Map<String, dynamic> json) {
    return DeliveryZoneEntity(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      centerLatitude: _toDouble(json['center_latitude']),
      centerLongitude: _toDouble(json['center_longitude']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'center_latitude': centerLatitude,
        'center_longitude': centerLongitude,
      };

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
