import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart';

class LocationDetails {
  const LocationDetails({
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.fullAddress,
  });

  final double latitude;
  final double longitude;
  final String name;
  final String fullAddress;
}

class LocationService {
  LocationService({Location? location}) : _location = location ?? Location();

  final Location _location;

  Future<LocationDetails?> getCurrentLocation() async {
    try {
      final serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) return null;

      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 1000,
        distanceFilter: 10,
      );

      final locationData = await _location.getLocation();
      final latitude = locationData.latitude;
      final longitude = locationData.longitude;

      if (latitude == null || longitude == null) {
        final retryData = await _location.getLocation();
        final retryLat = retryData.latitude;
        final retryLng = retryData.longitude;

        if (retryLat == null || retryLng == null) return null;

        return await geocodeLocation(retryLat, retryLng);
      }

      return await geocodeLocation(latitude, longitude);
    } catch (e) {
      print('LocationService error: $e');
      return null;
    }
  }

  Future<LocationDetails> geocodeLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isEmpty) {
        return _fallbackDetails(latitude, longitude);
      }

      final place = placemarks.first;
      final name = _firstNonEmpty([
            place.locality,
            place.subLocality,
            place.subAdministrativeArea,
            place.administrativeArea,
            place.country,
          ]) ??
          'Current location';
      final fullAddress = _joinNonEmpty([
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.postalCode,
        place.country,
      ]);

      return LocationDetails(
        latitude: latitude,
        longitude: longitude,
        name: name,
        fullAddress:
            fullAddress.isNotEmpty ? fullAddress : '$latitude, $longitude',
      );
    } catch (e, stackTrace) {
      print('Geocoding error: $e');
      print('Stack trace: $stackTrace');
      return _fallbackDetails(latitude, longitude);
    }
  }

  LocationDetails _fallbackDetails(double latitude, double longitude) {
    return LocationDetails(
      latitude: latitude,
      longitude: longitude,
      name: 'Current location',
      fullAddress: '$latitude, $longitude',
    );
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }

  String _joinNonEmpty(List<String?> values) {
    final parts = <String>[];
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) continue;
      if (!parts.contains(trimmed)) parts.add(trimmed);
    }
    return parts.join(', ');
  }
}
