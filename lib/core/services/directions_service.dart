import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heraj/core/config/google_maps_config.dart';
import 'package:heraj/core/utils/polyline_decoder.dart';

/// Road route from Google Directions API.
class DirectionsRoute {
  const DirectionsRoute({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
}

/// Fetches driving routes via Google Directions (same as kingo-delivery).
class DirectionsService {
  DirectionsService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 12),
                receiveTimeout: const Duration(seconds: 12),
              ),
            );

  final Dio _dio;

  static const _endpoint =
      'https://maps.googleapis.com/maps/api/directions/json';

  /// Driving route from [origin] to [destination], or `null` on failure.
  Future<DirectionsRoute?> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    if (!GoogleMapsConfig.isConfigured) return null;

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _endpoint,
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination':
              '${destination.latitude},${destination.longitude}',
          'mode': 'driving',
          'key': GoogleMapsConfig.apiKey,
        },
      );

      final data = response.data;
      if (data == null) return null;
      if (data['status']?.toString() != 'OK') return null;

      final routes = data['routes'];
      if (routes is! List || routes.isEmpty) return null;
      final route = routes.first;
      if (route is! Map) return null;

      final overview = route['overview_polyline'];
      final encoded = overview is Map ? overview['points']?.toString() : null;
      if (encoded == null || encoded.isEmpty) return null;

      final points = PolylineDecoder.decode(encoded);
      if (points.length < 2) return null;

      var distanceMeters = 0.0;
      var durationSeconds = 0.0;
      final legs = route['legs'];
      if (legs is List) {
        for (final leg in legs) {
          if (leg is! Map) continue;
          final distance = leg['distance'];
          final duration = leg['duration'];
          if (distance is Map && distance['value'] is num) {
            distanceMeters += (distance['value'] as num).toDouble();
          }
          if (duration is Map && duration['value'] is num) {
            durationSeconds += (duration['value'] as num).toDouble();
          }
        }
      }

      return DirectionsRoute(
        points: points,
        distanceMeters: distanceMeters,
        durationSeconds: durationSeconds,
      );
    } catch (_) {
      return null;
    }
  }
}
