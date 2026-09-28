class DistrictModel {
  final String name;
  final String nameTr;
  final String nameAr;

  DistrictModel({
    required this.name,
    required this.nameTr,
    required this.nameAr,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      name: json['name']?.toString() ?? '',
      nameTr: json['nameTr']?.toString() ?? '',
      nameAr: json['nameAr']?.toString() ?? '',
    );
  }

  String getLocalizedName(String locale) {
    switch (locale.toLowerCase()) {
      case 'tr':
        return nameTr;
      case 'ar':
        return nameAr;
      default:
        return name;
    }
  }
}

class NeighborhoodModel {
  final String name;
  final String nameTr;
  final String nameAr;

  NeighborhoodModel({
    required this.name,
    required this.nameTr,
    required this.nameAr,
  });

  factory NeighborhoodModel.fromJson(Map<String, dynamic> json) {
    return NeighborhoodModel(
      name: json['name']?.toString() ?? '',
      nameTr: json['nameTr']?.toString() ?? '',
      nameAr: json['nameAr']?.toString() ?? '',
    );
  }

  String getLocalizedName(String locale) {
    switch (locale.toLowerCase()) {
      case 'tr':
        return nameTr;
      case 'ar':
        return nameAr;
      default:
        return name;
    }
  }
}

class DistrictsResponse {
  final List<DistrictModel> districts;

  DistrictsResponse({required this.districts});

  factory DistrictsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['districts'] as List?;
    return DistrictsResponse(
      districts: list
              ?.whereType<Map<String, dynamic>>()
              .map(DistrictModel.fromJson)
              .toList() ??
          [],
    );
  }
}

class NeighborhoodsResponse {
  final List<NeighborhoodModel> neighborhoods;

  NeighborhoodsResponse({required this.neighborhoods});

  factory NeighborhoodsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['neighborhoods'] as List?;
    return NeighborhoodsResponse(
      neighborhoods: list
              ?.whereType<Map<String, dynamic>>()
              .map(NeighborhoodModel.fromJson)
              .toList() ??
          [],
    );
  }
}


