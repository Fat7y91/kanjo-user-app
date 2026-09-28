class BundleOrderHostEntity {
  final int id;
  final String name;

  const BundleOrderHostEntity({
    required this.id,
    required this.name,
  });

  factory BundleOrderHostEntity.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const BundleOrderHostEntity(id: 0, name: '');
    }
    return BundleOrderHostEntity(
      id: _intFrom(json['id']),
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  static int _intFrom(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
