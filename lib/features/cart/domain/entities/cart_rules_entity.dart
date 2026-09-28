class CartRulesEntity {
  final bool multiVendor;
  final int maxVendors;
  final double maxBranchDistanceKm;
  final double bundleShippingFactor;

  const CartRulesEntity({
    required this.multiVendor,
    required this.maxVendors,
    required this.maxBranchDistanceKm,
    required this.bundleShippingFactor,
  });

  factory CartRulesEntity.fromJson(Map<String, dynamic> json) {
    return CartRulesEntity(
      multiVendor: json['multi_vendor'] == true,
      maxVendors: json['max_vendors'] is int
          ? json['max_vendors'] as int
          : int.tryParse(json['max_vendors']?.toString() ?? '') ?? 0,
      maxBranchDistanceKm: json['max_branch_distance_km'] is num
          ? (json['max_branch_distance_km'] as num).toDouble()
          : double.tryParse(
                json['max_branch_distance_km']?.toString() ?? '',
              ) ??
              0,
      bundleShippingFactor: json['bundle_shipping_factor'] is num
          ? (json['bundle_shipping_factor'] as num).toDouble()
          : double.tryParse(
                json['bundle_shipping_factor']?.toString() ?? '',
              ) ??
              0,
    );
  }

  Map<String, dynamic> toJson() => {
        'multi_vendor': multiVendor,
        'max_vendors': maxVendors,
        'max_branch_distance_km': maxBranchDistanceKm,
        'bundle_shipping_factor': bundleShippingFactor,
      };
}
