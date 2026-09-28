import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/service/local_data_manager.dart';
import '../../../../core/service/remote_config_service.dart';
import '../../../../main.dart';
import '../../../settings/presentation/manager/fetch_settings_manager.dart';

enum SplashNavigate {
  home,
  boarding,
  login,
  forceUpdate,

  /// Settings/remote-config done; continue to GIF splash (or auth if no GIF).
  proceed,
}

final showOptionalUpdateDialogProvider =
    StateProvider.autoDispose<bool>((ref) => false);

final splashNavigateProvider = Provider.autoDispose<SplashNavigate>((ref) {
  if (dataManager.getToken() != null || dataManager.isGuest) {
    return SplashNavigate.home;
  }
  if (dataManager.isFirstTime) {
    return SplashNavigate.boarding;
  }
  return SplashNavigate.login;
});

final isUpdateAvailableProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});

/// Loads app settings + remote config. Does NOT call auth/me.
final splashProvider = FutureProvider.autoDispose<SplashNavigate>((ref) async {
  try {
    await ref.read(fetchSettingsProvider.future);
  } catch (_) {
    // Continue without blocking if settings fail
  }

  try {
    final remoteConfig = getIt<RemoteConfigService>();
    await remoteConfig.fetchAndActivate();
    final versionResult = await remoteConfig.checkVersion();
    switch (versionResult) {
      case VersionCheckResult.forceUpdate:
        return SplashNavigate.forceUpdate;
      case VersionCheckResult.optionalUpdate:
        ref.read(showOptionalUpdateDialogProvider.notifier).state = true;
        break;
      case VersionCheckResult.upToDate:
        break;
    }
  } catch (_) {
    // On error (e.g. no network), continue without blocking
  }

  return SplashNavigate.proceed;
});

final hasInternetProvider2 = StateProvider<bool>((ref) => true);

final isInternetOk = Provider<bool>((ref) {
  final connector1 = ref.watch(hasInternetProvider);
  final connector2 = ref.watch(hasInternetProvider2);
  if (connector1.isLoading) {
    return true;
  }
  if (connector1.hasValue) {
    if (connector1.value!) {
      return connector2;
    }
    return false;
  }
  return connector2;
});

final connectivity = Connectivity();

final hasInternetProvider = StreamProvider<bool>((ref) async* {
  ref.listenSelf((previous, next) {
    if (previous?.value == false && next.value == true) {
      ref.invalidate(hasInternetProvider2);
    }
  });
  final connectivityResult = await connectivity.checkConnectivity();
  yield connectivityResult.isOnline;
  yield* connectivity.onConnectivityChanged.map((event) => event.isOnline);
});

extension on List<ConnectivityResult> {
  bool get isOffline => contains(ConnectivityResult.none);

  bool get isOnline => !isOffline;
}
