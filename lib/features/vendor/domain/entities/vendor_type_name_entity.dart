class VendorTypeNameEntity {
  final String ar;
  final String en;

  const VendorTypeNameEntity({
    required this.ar,
    required this.en,
  });

  factory VendorTypeNameEntity.fromJson(Map<String, dynamic> json) {
    return VendorTypeNameEntity(
      ar: json['ar']?.toString() ?? '',
      en: json['en']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ar': ar,
      'en': en,
    };
  }

  String localized([String? languageCode]) {
    if (languageCode == 'ar') return ar.isNotEmpty ? ar : en;
    return en.isNotEmpty ? en : ar;
  }
}
