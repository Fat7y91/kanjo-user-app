class LocalizedNameEntity {
  final String ar;
  final String en;

  const LocalizedNameEntity({
    required this.ar,
    required this.en,
  });

  factory LocalizedNameEntity.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const LocalizedNameEntity(ar: '', en: '');
    }
    return LocalizedNameEntity(
      ar: json['ar']?.toString() ?? '',
      en: json['en']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'ar': ar,
        'en': en,
      };

  String localized([String? languageCode]) {
    if (languageCode == 'ar') return ar.isNotEmpty ? ar : en;
    return en.isNotEmpty ? en : ar;
  }
}
