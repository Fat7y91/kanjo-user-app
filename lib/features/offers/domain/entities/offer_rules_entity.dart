class OfferRulesEntity {
  const OfferRulesEntity({
    this.percent,
    this.buyQuantity,
    this.applyToPosition,
  });

  final double? percent;
  final int? buyQuantity;
  final int? applyToPosition;

  factory OfferRulesEntity.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OfferRulesEntity();
    return OfferRulesEntity(
      percent: json['percent'] is num
          ? (json['percent'] as num).toDouble()
          : double.tryParse(json['percent']?.toString() ?? ''),
      buyQuantity: json['buy_quantity'] is int
          ? json['buy_quantity'] as int
          : int.tryParse(json['buy_quantity']?.toString() ?? ''),
      applyToPosition: json['apply_to_position'] is int
          ? json['apply_to_position'] as int
          : int.tryParse(json['apply_to_position']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        if (percent != null) 'percent': percent,
        if (buyQuantity != null) 'buy_quantity': buyQuantity,
        if (applyToPosition != null) 'apply_to_position': applyToPosition,
      };
}
