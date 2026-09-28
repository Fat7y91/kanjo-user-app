class CartAppliedOfferEntity {
  final int id;
  final String type;
  final String name;
  final double savings;
  final double shippingDiscount;

  const CartAppliedOfferEntity({
    required this.id,
    required this.type,
    required this.name,
    required this.savings,
    required this.shippingDiscount,
  });

  factory CartAppliedOfferEntity.fromJson(Map<String, dynamic> json) {
    double money(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    return CartAppliedOfferEntity(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      type: json['type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      savings: money(json['savings']),
      shippingDiscount: money(json['shipping_discount']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'savings': savings,
        'shipping_discount': shippingDiscount,
      };
}
