import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heraj/core/services/directions_service.dart';
import 'package:heraj/core/utils/map_marker_icons.dart';
import 'package:heraj/features/orders/domain/entities/order_geo_point.dart';

/// Shared map overlays for order tracking (home ETA preview + track screen).
///
/// Polylines follow road geometry from Directions API when [routePoints] is
/// provided (same approach as kingo-delivery); otherwise falls back to a
/// straight line between endpoints.
class OrderTrackingMapOverlay {
  OrderTrackingMapOverlay._();

  static const routeColor = Color(0xFF7EB3B4);
  static final DirectionsService _directions = DirectionsService();

  static LatLng toLatLng(OrderGeoPoint point) =>
      LatLng(point.latitude, point.longitude);

  /// Fetches a driving route from [origin] → [destination].
  static Future<List<LatLng>?> fetchRoutePoints({
    required OrderGeoPoint? origin,
    required OrderGeoPoint? destination,
  }) async {
    if (origin == null || destination == null) return null;
    final route = await _directions.getRoute(
      origin: toLatLng(origin),
      destination: toLatLng(destination),
    );
    final points = route?.points;
    if (points == null || points.length < 2) return null;
    return points;
  }

  /// Road polyline when [routePoints] is set; else straight driver/pickup → dest.
  static Set<Polyline> polylines({
    required OrderGeoPoint? driver,
    required OrderGeoPoint? destination,
    OrderGeoPoint? pickup,
    List<LatLng>? routePoints,
  }) {
    if (destination == null) return {};

    final OrderGeoPoint? from = driver ?? pickup;
    if (from == null && (routePoints == null || routePoints.length < 2)) {
      return {};
    }

    final points = (routePoints != null && routePoints.length >= 2)
        ? routePoints
        : [
            toLatLng(from!),
            toLatLng(destination),
          ];

    return {
      Polyline(
        polylineId: const PolylineId('route_to_destination'),
        points: points,
        color: routeColor,
        width: 5,
      ),
    };
  }

  static Set<Marker> markers({
    required OrderGeoPoint? destination,
    required OrderGeoPoint? driver,
    OrderGeoPoint? pickup,
    BitmapDescriptor? driverIcon,
    BitmapDescriptor? destinationIcon,
    BitmapDescriptor? pickupIcon,
    String? destinationTitle,
    String? pickupTitle,
    String? driverTitle,
  }) {
    final markers = <Marker>{};

    if (pickup != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: toLatLng(pickup),
          icon: pickupIcon ?? MapMarkerIcons.vendor,
          infoWindow: InfoWindow(
            title: (pickupTitle ?? '').trim().isEmpty
                ? 'Pickup'
                : pickupTitle!.trim(),
          ),
          zIndexInt: 0,
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }

    if (destination != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: toLatLng(destination),
          icon: destinationIcon ?? MapMarkerIcons.customer,
          infoWindow: InfoWindow(
            title: (destinationTitle ?? '').trim().isEmpty
                ? 'Destination'
                : destinationTitle!.trim(),
          ),
          zIndexInt: 1,
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }

    if (driver != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: toLatLng(driver),
          icon: driverIcon ??
              BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange,
              ),
          infoWindow: InfoWindow(
            title: (driverTitle ?? '').trim().isEmpty
                ? 'Delivery partner'
                : driverTitle!.trim(),
          ),
          zIndexInt: 2,
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }

    return markers;
  }

  static List<LatLng> cameraPoints({
    OrderGeoPoint? pickup,
    OrderGeoPoint? destination,
    OrderGeoPoint? driver,
    List<LatLng>? routePoints,
  }) {
    return [
      if (driver != null) toLatLng(driver),
      if (destination != null) toLatLng(destination),
      if (pickup != null) toLatLng(pickup),
      ...?routePoints,
    ];
  }
}
