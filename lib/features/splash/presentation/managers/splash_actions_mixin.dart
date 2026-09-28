import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/core/service/deep_linking_service/deep_linking_service.dart';
import 'package:heraj/features/offline/no_wifi.dart';
import 'package:heraj/main.dart';
import 'package:heraj/features/settings/presentation/manager/fetch_settings_manager.dart';
import 'package:heraj/features/splash/presentation/managers/splash_gif_cache.dart';
import 'package:heraj/features/splash/presentation/managers/splash_navigation_mixin.dart';
import 'package:heraj/features/splash/presentation/managers/splash_provider.dart';
import 'package:heraj/features/splash/presentation/view/gif_splash_view.dart';

mixin SplashActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T>, SplashNavigationMixin<T> {
  Future<bool> ensureRealDevice() async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<void> checkRealDeviceOrExit() async {
    if (!await ensureRealDevice()) {
      Get.offAll(() => const ViolationScreen());
    }
  }

  Future<void> startGifPrecache(String? url) async {
    final gifUrl = url?.trim();
    if (gifUrl == null || gifUrl.isEmpty || !mounted) return;
    try {
      await SplashGifCache.precache(context, gifUrl);
    } catch (e) {
      if (kDebugMode) {
        print('Splash GIF precache failed: $e');
      }
    }
  }

  void onSplashReady(SplashNavigate route) {
    final hasPendingNotification =
        dataManager.getValue('pending_notification') != null;
    if (hasPendingNotification) {
      if (kDebugMode) {
        print('Pending notification detected, skipping splash navigation');
      }
      // Still allow warm deep links after splash is left via notification path.
      getIt<DeepLinkService>().markAppReady();
      return;
    }
    if (route == SplashNavigate.forceUpdate) {
      return;
    }
    continueAfterLogoSplash();
  }

  Future<void> continueAfterLogoSplash() async {
    final gifUrl = ref.read(appSettingsProvider)?.mobileSplashGifUrl?.trim();
    if (gifUrl != null && gifUrl.isNotEmpty) {
      // Block until the GIF is fully in memory. Do not open GIF screen early.
      try {
        await SplashGifCache.precache(context, gifUrl);
      } catch (e) {
        if (kDebugMode) {
          print('Splash GIF final precache failed: $e');
        }
      }
      if (!mounted) return;

      if (SplashGifCache.isReady && SplashGifCache.provider != null) {
        Get.offAll(() => GifSplashView(gifUrl: gifUrl));
        return;
      }

      // Last attempt — still open GIF screen; it will use network fallback.
      Get.offAll(() => GifSplashView(gifUrl: gifUrl));
      return;
    }

    final shareResolveFuture = getIt<DeepLinkService>().resolvePending();
    final route = await resolveAuthNavigation();
    await shareResolveFuture;
    if (!mounted) return;
    await finishSplashNavigation(route);
  }
}
