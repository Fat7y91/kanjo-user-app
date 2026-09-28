import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

final _logger = Logger();

class RemoteConfigKeys {
  static const minimumAppVersion = 'minimum_app_version';
  static const warningAppVersion = 'warning_app_version';
  static const appleUpdateLink = 'apple_update_link';
  static const googleUpdateLink = 'google_update_link';
}

enum VersionCheckResult {
  upToDate,
  optionalUpdate,
  forceUpdate,
}

class RemoteConfigService {
  RemoteConfigService() {
    _remoteConfig = FirebaseRemoteConfig.instance;
  }

  late final FirebaseRemoteConfig _remoteConfig;

  Future<void> fetchAndActivate() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(minutes: 1),
      ));
      final activated = await _remoteConfig.fetchAndActivate();
      _logger.i(
        '[RemoteConfig] fetchAndActivate: activated=$activated | '
        'minimum_app_version=$_minimumVersion | '
        'warning_app_version=$_warningVersion | '
        'apple_update_link=${appStoreLink.isEmpty ? "(empty)" : appStoreLink} | '
        'google_update_link=${playStoreLink.isEmpty ? "(empty)" : playStoreLink}',
      );
    } catch (e, st) {
      _logger.e('[RemoteConfig] fetchAndActivate failed',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  String get _minimumVersion => _stripQuotes(
      _remoteConfig.getString(RemoteConfigKeys.minimumAppVersion).trim());

  String get _warningVersion => _stripQuotes(
      _remoteConfig.getString(RemoteConfigKeys.warningAppVersion).trim());

  String get playStoreLink => _stripQuotes(
      _remoteConfig.getString(RemoteConfigKeys.googleUpdateLink).trim());

  String get appStoreLink => _stripQuotes(
      _remoteConfig.getString(RemoteConfigKeys.appleUpdateLink).trim());

  String get storeLink => Platform.isIOS ? appStoreLink : playStoreLink;

  Future<VersionCheckResult> checkVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentStr = packageInfo.version;
    final current = _normalizeVersion(currentStr);
    final minStr = _minimumVersion;
    final warningStr = _warningVersion;
    final min = _normalizeVersion(minStr);
    final warning = _normalizeVersion(warningStr);

    VersionCheckResult result;
    if (_compareVersions(current, min) < 0) {
      result = VersionCheckResult.forceUpdate;
    } else if (_compareVersions(current, warning) < 0) {
      result = VersionCheckResult.optionalUpdate;
    } else {
      result = VersionCheckResult.upToDate;
    }

    _logger.i(
      '[RemoteConfig] checkVersion: current=$currentStr | '
      'minimum=$minStr | warning=$warningStr => $result',
    );
    return result;
  }

  /// Remove surrounding double quotes (Firebase console may store "1.0.1" as literal).
  static String _stripQuotes(String s) {
    if (s.length >= 2 && s.startsWith('"') && s.endsWith('"')) {
      return s.substring(1, s.length - 1);
    }
    return s;
  }

  List<int> _normalizeVersion(String v) {
    final main = v.split(RegExp(r'\+|-')).first.trim();
    return main.split('.').map((e) => int.tryParse(e.trim()) ?? 0).toList();
  }

  int _compareVersions(List<int> a, List<int> b) {
    final len = a.length > b.length ? a.length : b.length;
    for (var i = 0; i < len; i++) {
      final va = i < a.length ? a[i] : 0;
      final vb = i < b.length ? b[i] : 0;
      if (va != vb) return va - vb;
    }
    return 0;
  }
}
