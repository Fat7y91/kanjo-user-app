class PackageSizeEntity {
  const PackageSizeEntity({
    required this.id,
    required this.name,
    required this.heightCm,
    required this.widthCm,
    required this.lengthCm,
    required this.sizeMultiplier,
    required this.isActive,
    required this.sortOrder,
  });

  final int id;
  final String name;
  final double heightCm;
  final double widthCm;
  final double lengthCm;
  final double sizeMultiplier;
  final bool isActive;
  final int sortOrder;

  String get dimensionsLabel =>
      '${heightCm.toStringAsFixed(0)}×${widthCm.toStringAsFixed(0)}×${lengthCm.toStringAsFixed(0)} cm';

  factory PackageSizeEntity.fromJson(Map<String, dynamic> json) {
    return PackageSizeEntity(
      id: _toInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      heightCm: _toDouble(json['height_cm']) ?? 0,
      widthCm: _toDouble(json['width_cm']) ?? 0,
      lengthCm: _toDouble(json['length_cm']) ?? 0,
      sizeMultiplier: _toDouble(json['size_multiplier']) ?? 1,
      isActive: json['is_active'] == true,
      sortOrder: _toInt(json['sort_order']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'height_cm': heightCm,
        'width_cm': widthCm,
        'length_cm': lengthCm,
        'size_multiplier': sizeMultiplier,
        'is_active': isActive,
        'sort_order': sortOrder,
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
