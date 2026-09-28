import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_data_manager.dart';

final isDarkModeProvider = StateProvider<bool>((ref) {
  if (dataManager.isDarkMode() == null) {
    SchedulerBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        () {
      ref.invalidateSelf();
    };
  }
  ref.onDispose(() {
    SchedulerBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        null;
  });

  final isDarkMode =
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
  return dataManager.isDarkMode() ?? isDarkMode;
});
