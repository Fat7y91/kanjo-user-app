class CartVendorRefEntity {
  const CartVendorRefEntity({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory CartVendorRefEntity.fromJson(Map<String, dynamic> json) {
    return CartVendorRefEntity(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
