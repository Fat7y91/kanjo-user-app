import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heraj/config/app_color.dart';

/// Map marker icons — same circular pin style as kingo-delivery
/// (driver / vendor / customer destination).
abstract final class MapMarkerIcons {
  static const double _pinSize = 56;
  static const int _version = 2;

  static BitmapDescriptor? _driver;
  static BitmapDescriptor? _vendor;
  static BitmapDescriptor? _customer;
  static int? _loadedVersion;

  static BitmapDescriptor get driver =>
      _driver ??
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

  static BitmapDescriptor get vendor =>
      _vendor ??
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);

  static BitmapDescriptor get customer =>
      _customer ??
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);

  static bool get isReady =>
      _loadedVersion == _version &&
      _driver != null &&
      _vendor != null &&
      _customer != null;

  /// Builds icons once and reuses them.
  static Future<void> ensureLoaded() async {
    if (isReady) return;
    final results = await Future.wait([
      _pin(
        icon: Icons.my_location_rounded,
        color: AppColor.primary,
      ),
      _pin(
        icon: Icons.storefront_rounded,
        color: AppColor.guestOrange,
      ),
      _pin(
        icon: Icons.person_rounded,
        color: AppColor.primary,
      ),
    ]);
    _driver = results[0];
    _vendor = results[1];
    _customer = results[2];
    _loadedVersion = _version;
  }

  static void reset() {
    _driver = null;
    _vendor = null;
    _customer = null;
    _loadedVersion = null;
  }

  static Future<BitmapDescriptor> _pin({
    required IconData icon,
    required Color color,
  }) async {
    const size = _pinSize;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2);

    final shadow = Paint()
      ..color = Colors.black.withAlpha(41)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(center.translate(0, 1.5), size * 0.36, shadow);

    canvas.drawCircle(
      center,
      size * 0.36,
      Paint()..color = Colors.white,
    );

    canvas.drawCircle(
      center,
      size * 0.36,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final textPainter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size * 0.4,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      )
      ..layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    final image = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }
}
