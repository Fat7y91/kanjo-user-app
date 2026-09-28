import 'package:flutter/foundation.dart';

@immutable
class OrderGeoPoint {
  const OrderGeoPoint({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  static OrderGeoPoint? tryParse(dynamic raw) {
    if (raw == null) return null;
    if (raw is OrderGeoPoint) return raw;

    if (raw is List && raw.length >= 2) {
      final lat = _asDouble(raw[0]);
      final lng = _asDouble(raw[1]);
      // Some APIs send [lng, lat]
      if (lat != null && lng != null) {
        if (lat.abs() <= 90 && lng.abs() <= 180) {
          return OrderGeoPoint(latitude: lat, longitude: lng);
        }
        if (lng.abs() <= 90 && lat.abs() <= 180) {
          return OrderGeoPoint(latitude: lng, longitude: lat);
        }
      }
    }

    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final nested = map['location'] ?? map['coordinates'] ?? map['point'];
    if (nested != null && nested is! Map) {
      final fromNested = tryParse(nested);
      if (fromNested != null) return fromNested;
    }
    if (nested is Map) {
      final fromNested = tryParse(nested);
      if (fromNested != null) return fromNested;
    }

    final lat = _asDouble(
      map['latitude'] ?? map['lat'] ?? map['driver_lat'] ?? map['y'],
    );
    final lng = _asDouble(
      map['longitude'] ??
          map['lng'] ??
          map['lon'] ??
          map['long'] ??
          map['driver_lng'] ??
          map['x'],
    );
    if (lat == null || lng == null) return null;
    if (lat == 0 && lng == 0) return null;
    return OrderGeoPoint(latitude: lat, longitude: lng);
  }

  static double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
