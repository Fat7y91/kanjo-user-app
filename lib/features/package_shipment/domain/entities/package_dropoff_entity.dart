class PackageDropoffEntity {
  const PackageDropoffEntity({
    required this.id,
    required this.sequence,
    required this.receiverName,
    required this.receiverPhone,
    required this.dropoffAddress,
    required this.dropoffLat,
    required this.dropoffLng,
    this.zoneId,
    required this.status,
    this.deliveredAt,
  });

  final int id;
  final int sequence;
  final String receiverName;
  final String receiverPhone;
  final String dropoffAddress;
  final double dropoffLat;
  final double dropoffLng;
  final int? zoneId;
  final String status;
  final DateTime? deliveredAt;

  factory PackageDropoffEntity.fromJson(Map<String, dynamic> json) {
    return PackageDropoffEntity(
      id: _toInt(json['id']) ?? 0,
      sequence: _toInt(json['sequence']) ?? 0,
      receiverName: json['receiver_name']?.toString() ?? '',
      receiverPhone: json['receiver_phone']?.toString() ?? '',
      dropoffAddress: _firstText(json, const [
        'address_details',
        'dropoff_address',
      ]),
      dropoffLat: _toDouble(json['dropoff_lat']) ?? 0,
      dropoffLng: _toDouble(json['dropoff_lng']) ?? 0,
      zoneId: _toInt(json['zone_id']),
      status: json['status']?.toString() ?? '',
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sequence': sequence,
        'receiver_name': receiverName,
        'receiver_phone': receiverPhone,
        'dropoff_address': dropoffAddress,
        'address_details': dropoffAddress,
        'dropoff_lat': dropoffLat,
        'dropoff_lng': dropoffLng,
        'zone_id': zoneId,
        'status': status,
        'delivered_at': deliveredAt?.toIso8601String(),
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

  static String _firstText(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }
}
