import 'package:heraj/features/products/domain/entities/localized_name_entity.dart';

class RewardModel {
  const RewardModel({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredPoints,
    required this.discountType,
    required this.discountValue,
    required this.maximumDiscountAmount,
    required this.minimumOrderAmount,
    required this.maximumUsagePerUser,
    required this.status,
    required this.canUse,
    this.validFrom,
    this.validTo,
    this.unavailableReason,
  });

  final int id;
  final LocalizedNameEntity name;
  final LocalizedNameEntity description;
  final int requiredPoints;
  final String discountType;
  final double discountValue;
  final double maximumDiscountAmount;
  final double minimumOrderAmount;
  final int maximumUsagePerUser;
  final DateTime? validFrom;
  final DateTime? validTo;
  final String status;
  final bool canUse;
  final String? unavailableReason;

  bool get isPercentDiscount {
    final type = discountType.toLowerCase().trim();
    return type == 'percent' || type == 'percentage' || type == '%';
  }

  bool isUsable(int availablePoints) {
    if (availablePoints < requiredPoints) return false;
    if (!canUse) return false;
    if (status.toLowerCase() != 'active') return false;
    return true;
  }

  bool isValidForCheckout({
    required int availablePoints,
    required double orderAmount,
  }) {
    if (!isUsable(availablePoints)) return false;
    if (minimumOrderAmount > 0 && orderAmount < minimumOrderAmount) {
      return false;
    }
    return true;
  }

  double discountAmountFor(double orderAmount) {
    if (orderAmount <= 0) return 0;
    if (minimumOrderAmount > 0 && orderAmount < minimumOrderAmount) return 0;
    var amount = isPercentDiscount
        ? orderAmount * (discountValue / 100)
        : discountValue;
    if (maximumDiscountAmount > 0 && amount > maximumDiscountAmount) {
      amount = maximumDiscountAmount;
    }
    if (amount > orderAmount) amount = orderAmount;
    if (amount < 0) return 0;
    return amount;
  }

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: _intFrom(json['id']),
      name: _localized(json['name']),
      description: _localized(json['description']),
      requiredPoints: _intFrom(json['required_points']),
      discountType: json['discount_type']?.toString() ?? '',
      discountValue: _doubleFrom(json['discount_value']),
      maximumDiscountAmount: _doubleFrom(json['maximum_discount_amount']),
      minimumOrderAmount: _doubleFrom(json['minimum_order_amount']),
      maximumUsagePerUser: _intFrom(json['maximum_usage_per_user']),
      validFrom: DateTime.tryParse(json['valid_from']?.toString() ?? ''),
      validTo: DateTime.tryParse(json['valid_to']?.toString() ?? ''),
      status: json['status']?.toString() ?? '',
      canUse: json['can_use'] == true,
      unavailableReason: json['unavailable_reason']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name.toJson(),
        'description': description.toJson(),
        'required_points': requiredPoints,
        'discount_type': discountType,
        'discount_value': discountValue,
        'maximum_discount_amount': maximumDiscountAmount,
        'minimum_order_amount': minimumOrderAmount,
        'maximum_usage_per_user': maximumUsagePerUser,
        'valid_from': validFrom?.toIso8601String(),
        'valid_to': validTo?.toIso8601String(),
        'status': status,
        'can_use': canUse,
        'unavailable_reason': unavailableReason,
      };
}

LocalizedNameEntity _localized(dynamic value) {
  if (value is Map) {
    return LocalizedNameEntity.fromJson(Map<String, dynamic>.from(value));
  }
  if (value is String && value.trim().isNotEmpty) {
    return LocalizedNameEntity(ar: value, en: value);
  }
  return const LocalizedNameEntity(ar: '', en: '');
}

int _intFrom(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _doubleFrom(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
