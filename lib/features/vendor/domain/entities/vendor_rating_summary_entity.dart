class VendorRatingSummaryEntity {
  final double? average;
  final int count;

  const VendorRatingSummaryEntity({
    this.average,
    required this.count,
  });

  factory VendorRatingSummaryEntity.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const VendorRatingSummaryEntity(count: 0);
    }
    return VendorRatingSummaryEntity(
      average: json['average'] is num
          ? (json['average'] as num).toDouble()
          : double.tryParse(json['average']?.toString() ?? ''),
      count: json['count'] is int
          ? json['count'] as int
          : int.tryParse(json['count']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'average': average,
        'count': count,
      };
}
