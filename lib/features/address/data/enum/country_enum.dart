import 'package:get/get.dart';

enum CountryEnum {
  turkey('Turkey'),
  egypt('Egypt'),
  usa('USA'),
  saudiArabia('Saudi Arabia'),
  uae('UAE'),
  kuwait('Kuwait'),
  qatar('Qatar');

  final String value;

  const CountryEnum(this.value);

  String get displayName => value.tr;

  static CountryEnum? fromString(String? value) {
    if (value == null) return null;
    try {
      return CountryEnum.values.firstWhere(
        (country) => country.value == value,
        orElse: () => CountryEnum.turkey, // Default to Turkey
      );
    } catch (e) {
      return CountryEnum.turkey; // Default to Turkey
    }
  }

  static List<CountryEnum> get allCountries => CountryEnum.values;

  static CountryEnum get defaultCountry => CountryEnum.turkey;
}

