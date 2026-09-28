import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';

import '../../../main.dart';
import 'location_service.dart';

final fetchLocationDetailsProvider =
    FutureProvider.autoDispose<LocationDetails?>((ref) async {
  try {
    final location = Location();

    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    var permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
    }
    final isGranted = permission == PermissionStatus.granted ||
        permission == PermissionStatus.grantedLimited;

    if (!isGranted) {
      return null;
    }
    final locationService = getIt<LocationService>();
    final details = await locationService.getCurrentLocation();
    if (details == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      return await locationService.getCurrentLocation();
    }

    return details;
  } catch (e) {
    print('LocationProvider error: $e');
    return null;
  }
});
