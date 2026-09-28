import 'package:heraj/config/app_string.dart';

/// Google Maps / Directions API key (from env via [AppString]).
abstract class GoogleMapsConfig {
  static String get apiKey => AppString.googleMapsApiKey.trim();

  static bool get isConfigured =>
      apiKey.isNotEmpty && apiKey != 'replace_with_google_maps_api_key';
}
