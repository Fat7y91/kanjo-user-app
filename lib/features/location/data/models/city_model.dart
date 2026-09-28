class CityModel {
  final String code;
  final String name;
  final String nameTr;
  final String nameAr;

  CityModel({
    required this.code,
    required this.name,
    required this.nameTr,
    required this.nameAr,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameTr: json['nameTr']?.toString() ?? '',
      nameAr: json['nameAr']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'nameTr': nameTr,
      'nameAr': nameAr,
    };
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

class CitiesResponse {
  final List<CityModel> cities;

  CitiesResponse({required this.cities});

  factory CitiesResponse.fromJson(Map<String, dynamic> json) {
    final citiesList = json['cities'] as List?;
    return CitiesResponse(
      cities: citiesList?.map((city) => CityModel.fromJson(city)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cities': cities.map((city) => city.toJson()).toList(),
    };
  }
}

