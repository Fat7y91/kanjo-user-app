import 'dart:ui';

import 'package:get/get.dart';

import '../../../main.dart';
import '../../enum/language.dart';
import '../local_data_manager.dart';

LocaleService localeService = getIt<LocaleService>();

class LocaleService {
  final LocalDataManager dataManager;

  LocaleService(this.dataManager);

  Locale get handleLocaleInMain {
    return getLocale().locale;
  }

  Language getLocale() {
    return dataManager.getLanguage ?? defaultLanguage;
  }

  Future<void> changeLocale(Language language) async {
    Get.updateLocale(language.locale);
    await dataManager.setLanguage(language);
  }

  Future<void> toggleLocale() async {
    if (!isArabic) {
      changeLocale(Language.arabic);
    } else {
      changeLocale(Language.english);
    }
  }

  Locale get defaultLocale => defaultLanguage.locale;

  Language get defaultLanguage => Language.values.first;

  List<Language> get getAllLanguages => Language.values;

  bool get isArabic => Get.locale == Language.arabic.locale;
}
