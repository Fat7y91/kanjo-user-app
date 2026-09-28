import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/core/service/deep_linking_service/deep_linking_service.dart';
import 'package:heraj/features/splash/presentation/managers/splash_navigation_mixin.dart';
import 'package:heraj/main.dart';

mixin GifSplashActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T>, SplashNavigationMixin<T> {
  static const gifDisplayDuration = Duration(seconds: 3);

  ValueNotifier<bool> get isResolvingAuth;

  Future<void> runGifSplashFlow() async {
    final shareResolveFuture = getIt<DeepLinkService>().resolvePending();

    await Future.delayed(gifDisplayDuration);
    if (!mounted) return;

    isResolvingAuth.value = true;
    final authFuture = resolveAuthNavigation();
    await shareResolveFuture;
    final route = await authFuture;
    if (!mounted) return;
    isResolvingAuth.value = false;
    await finishSplashNavigation(route);
  }
}
