class CartCouponEntity {
  final int id;
  final String code;
  final String type;
  final String name;
  final int sequence;
  final double discountAmount;
  final double shippingDiscount;
  final double cashbackAmount;
  final double budgetAppliedAmount;
  final String fundedBy;
  final double vendorFundingPercent;

  const CartCouponEntity({
    required this.id,
    required this.code,
    required this.type,
    required this.name,
    this.sequence = 0,
    this.discountAmount = 0,
    this.shippingDiscount = 0,
    this.cashbackAmount = 0,
    this.budgetAppliedAmount = 0,
    this.fundedBy = '',
    this.vendorFundingPercent = 0,
  });

  bool get hasDiscountValue =>
      discountAmount > 0 || shippingDiscount > 0 || cashbackAmount > 0;

  String get displayTitle {
    final label = name.trim().isNotEmpty ? name.trim() : code.trim();
    if (label.isEmpty) return '';
    if (code.trim().isNotEmpty && label != code.trim()) {
      return '$label ($code)';
    }
    return label;
  }

  factory CartCouponEntity.fromJson(Map<String, dynamic> json) {
    double money(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    return CartCouponEntity(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      code: json['code']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sequence: json['sequence'] is int
          ? json['sequence'] as int
          : int.tryParse(json['sequence']?.toString() ?? '') ?? 0,
      discountAmount: money(json['discount_amount']),
      shippingDiscount: money(json['shipping_discount']),
      cashbackAmount: money(json['cashback_amount']),
      budgetAppliedAmount: money(json['budget_applied_amount']),
      fundedBy: json['funded_by']?.toString() ?? '',
      vendorFundingPercent: money(json['vendor_funding_percent']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'type': type,
        'name': name,
        'sequence': sequence,
        'discount_amount': discountAmount,
        'shipping_discount': shippingDiscount,
        'cashback_amount': cashbackAmount,
        'budget_applied_amount': budgetAppliedAmount,
        'funded_by': fundedBy,
        'vendor_funding_percent': vendorFundingPercent,
      };
}
