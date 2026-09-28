class CategoryNameEntity {
  final String ar;
  final String en;

  const CategoryNameEntity({
    required this.ar,
    required this.en,
  });

  factory CategoryNameEntity.fromJson(Map<String, dynamic> json) {
    return CategoryNameEntity(
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
