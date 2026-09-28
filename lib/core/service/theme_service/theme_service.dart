import 'package:heraj/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_theme.dart';
import '../local_data_manager.dart';

ThemeService themeService = getIt<ThemeService>();

class ThemeService extends GetxService {

  final LocalDataManager dataManager;

  RxBool _isDarkMode = false.obs;

  ThemeService(this.dataManager) : _isDarkMode = RxBool(dataManager.isDarkMode() ?? false);

  ThemeData get currentTheme => isDarkMode ? getDarkTheme() : getLightTheme();

  bool get isDarkMode => _isDarkMode.value;

  ThemeMode get getThemeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme() async {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeThemeMode(getThemeMode); // Automatically binds to ThemeMode
    await dataManager.setIsDarkMode(_isDarkMode.value);
  }
}
