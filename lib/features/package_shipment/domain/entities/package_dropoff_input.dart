class PackageDropoffInput {
  const PackageDropoffInput({
    required this.receiverName,
    required this.receiverPhone,
    required this.dropoffLat,
    required this.dropoffLng,
    this.dropoffAddress = '',
  });

  final String receiverName;
  final String receiverPhone;
  final double dropoffLat;
  final double dropoffLng;
  final String dropoffAddress;

  bool get isValid =>
      receiverName.trim().isNotEmpty &&
      receiverPhone.trim().isNotEmpty &&
      dropoffLat != 0 &&
      dropoffLng != 0;

  PackageDropoffInput copyWith({
    String? receiverName,
    String? receiverPhone,
    double? dropoffLat,
    double? dropoffLng,
    String? dropoffAddress,
  }) {
    return PackageDropoffInput(
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
    );
  }

  Map<String, dynamic> toJson() => {
        'receiver_name': receiverName,
        'receiver_phone': receiverPhone,
        'dropoff_lat': dropoffLat,
        'dropoff_lng': dropoffLng,
        'dropoff_address': dropoffAddress,
        'address_details': dropoffAddress,
      };

  factory PackageDropoffInput.fromJson(Map<String, dynamic> json) {
    return PackageDropoffInput(
      receiverName: json['receiver_name']?.toString() ?? '',
      receiverPhone: json['receiver_phone']?.toString() ?? '',
      dropoffLat: (json['dropoff_lat'] as num?)?.toDouble() ?? 0,
      dropoffLng: (json['dropoff_lng'] as num?)?.toDouble() ?? 0,
      dropoffAddress: _firstText(json, const [
        'address_details',
        'dropoff_address',
      ]),
    );
  }

  static String _firstText(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }
}
