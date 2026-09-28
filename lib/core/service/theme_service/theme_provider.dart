import 'package:heraj/core/service/theme_service/theme_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateProvider<ThemeService>((ref) {
  return themeService;
});
