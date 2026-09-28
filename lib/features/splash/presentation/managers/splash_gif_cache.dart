import 'package:flutter/material.dart';

/// Holds the splash GIF after it is fully decoded during [SplashView].
class SplashGifCache {
  SplashGifCache._();

  static String? url;
  static NetworkImage? provider;
  static Future<void>? _future;
  static bool isReady = false;

  static Future<void> precache(BuildContext context, String gifUrl) {
    final trimmed = gifUrl.trim();
    if (trimmed.isEmpty) return Future.value();

    if (url == trimmed && isReady && provider != null) {
      return Future.value();
    }
    if (url == trimmed && _future != null) {
      return _future!;
    }

    url = trimmed;
    isReady = false;
    provider = NetworkImage(trimmed);
    final image = provider!;

    _future = () async {
      await precacheImage(image, context);
      isReady = true;
    }();

    return _future!;
  }

  static void clear() {
    url = null;
    provider = null;
    _future = null;
    isReady = false;
  }
}
