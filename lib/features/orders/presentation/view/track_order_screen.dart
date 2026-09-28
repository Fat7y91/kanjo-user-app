import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/utils/map_marker_icons.dart';
import 'package:heraj/features/orders/domain/entities/order_details_entity.dart';
import 'package:heraj/features/orders/domain/entities/order_entity.dart';
import 'package:heraj/features/orders/domain/entities/order_geo_point.dart';
import 'package:heraj/features/orders/presentation/manager/orders_provider.dart';
import 'package:heraj/features/orders/presentation/managers/order_tracking_location_provider.dart';
import 'package:heraj/features/orders/presentation/view/widgets/order_tracking_map_overlay.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TrackOrderScreen extends ConsumerStatefulWidget {
  const TrackOrderScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  ConsumerState<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends ConsumerState<TrackOrderScreen> {
  static const _fallbackTarget = LatLng(30.0444, 31.2357);

  GoogleMapController? _mapController;
  LatLng? _lastCameraTarget;
  BitmapDescriptor? _driverMarkerIcon;
  List<LatLng>? _routePoints;
  int _routeFetchGeneration = 0;
  String? _lastRouteKey;

  @override
  void initState() {
    super.initState();
    _loadMarkerIcons();
  }

  Future<void> _loadMarkerIcons() async {
    await MapMarkerIcons.ensureLoaded();
    if (mounted) setState(() {});
    try {
      final icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(96, 96)),
        AppAssets.kanjoDelivery,
      );
      if (!mounted) return;
      setState(() => _driverMarkerIcon = icon);
    } catch (_) {
      // Keep default marker if asset fails to load.
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadRoute({
    required OrderGeoPoint? origin,
    required OrderGeoPoint? destination,
  }) async {
    final key = origin == null || destination == null
        ? null
        : '${origin.latitude},${origin.longitude}->'
            '${destination.latitude},${destination.longitude}';
    if (key == null) {
      if (_routePoints != null) setState(() => _routePoints = null);
      _lastRouteKey = null;
      return;
    }
    if (key == _lastRouteKey) return;
    _lastRouteKey = key;
    final generation = ++_routeFetchGeneration;

    final points = await OrderTrackingMapOverlay.fetchRoutePoints(
      origin: origin,
      destination: destination,
    );
    if (!mounted || generation != _routeFetchGeneration) return;
    setState(() => _routePoints = points);
    await _fitCamera(
      pickup: null,
      destination: destination,
      driver: origin,
    );
  }

  Future<void> _fitCamera({
    required OrderGeoPoint? pickup,
    required OrderGeoPoint? destination,
    required OrderGeoPoint? driver,
  }) async {
    final controller = _mapController;
    if (controller == null) return;

    final points = OrderTrackingMapOverlay.cameraPoints(
      pickup: pickup,
      destination: destination,
      driver: driver,
      routePoints: _routePoints,
    );
    if (points.isEmpty) return;

    if (points.length == 1) {
      final target = points.first;
      if (_lastCameraTarget != null &&
          _samePoint(_lastCameraTarget!, target)) {
        return;
      }
      _lastCameraTarget = target;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 15),
        ),
      );
      return;
    }

    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;
    for (final p in points.skip(1)) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    _lastCameraTarget = LatLng(
      (minLat + maxLat) / 2,
      (minLng + maxLng) / 2,
    );
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 72),
    );
  }

  bool _samePoint(LatLng a, LatLng b) =>
      (a.latitude - b.latitude).abs() < 0.00001 &&
      (a.longitude - b.longitude).abs() < 0.00001;

  Future<void> _callDriver(String? phone) async {
    final raw = phone?.trim() ?? '';
    if (raw.isEmpty) return;
    final uri = raw.startsWith('tel:') ? raw : 'tel:$raw';
    await launchUrlString(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(fetchOrderDetailsProvider(widget.orderId));
    final driverAsync =
        ref.watch(orderTrackingLocationProvider(widget.orderId));

    ref.listen(orderTrackingLocationProvider(widget.orderId), (previous, next) {
      final details = detailsAsync.valueOrNull;
      final live = next.valueOrNull;
      if (details == null || live == null) return;
      final origin = live.location;
      final destination = details.destinationLocation;
      _loadRoute(origin: origin, destination: destination);
      _fitCamera(
        pickup: details.pickupLocation,
        destination: destination,
        driver: origin,
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: detailsAsync.customWhen(
        ref: ref,
        refreshable: fetchOrderDetailsProvider(widget.orderId).future,
        loading: () => const PageLoadingWidget(),
        data: (details) {
          final live = driverAsync.valueOrNull;
          final driverPoint = live?.location ?? details.driverLocation;
          final liveName = live?.displayName?.trim() ?? '';
          final partnerName = liveName.isNotEmpty
              ? liveName
              : details.deliveryPartnerName;
          final partnerId = live?.partnerId ?? details.deliveryPartnerId;
          final destination = details.destinationLocation;
          final pickup = details.pickupLocation;
          final routeOrigin = driverPoint ?? pickup;
          final initialTarget = driverPoint ??
              destination ??
              pickup ??
              OrderGeoPoint(
                latitude: _fallbackTarget.latitude,
                longitude: _fallbackTarget.longitude,
              );

          // Kick off Directions fetch when endpoints are known.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _loadRoute(origin: routeOrigin, destination: destination);
          });

          return Stack(
            children: [
              Positioned.fill(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: OrderTrackingMapOverlay.toLatLng(initialTarget),
                    zoom: 14,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      _fitCamera(
                        pickup: pickup,
                        destination: destination,
                        driver: driverPoint,
                      );
                    });
                  },
                  markers: OrderTrackingMapOverlay.markers(
                    destination: destination,
                    driver: driverPoint,
                    pickup: pickup,
                    driverIcon: _driverMarkerIcon,
                    destinationTitle: details.destinationTitle.isNotEmpty
                        ? details.destinationTitle
                        : details.destinationAddress,
                    pickupTitle: details.pickupTitle.isNotEmpty
                        ? details.pickupTitle
                        : 'Pickup'.tr,
                    driverTitle: partnerName.isNotEmpty
                        ? partnerName
                        : 'Delivery partner'.tr,
                  ),
                  polylines: OrderTrackingMapOverlay.polylines(
                    destination: destination,
                    driver: driverPoint,
                    pickup: pickup,
                    routePoints: _routePoints,
                  ),
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Get.back(),
                        borderRadius: BorderRadius.circular(12),
                        child: const SizedBox(
                          width: 24,
                          height: 24,
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 18,
                            color: Color(0xFF111111),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Track order'.tr,
                          textAlign: TextAlign.center,
                          style: AppFont.font18W700Black.copyWith(
                            color: const Color(0xFF111111),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24, height: 24),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _TrackingBottomPanel(
                  details: details,
                  partnerName: partnerName,
                  partnerId: partnerId,
                  statusText: _statusText(details.status),
                  onCall: () => _callDriver(details.deliveryPartnerPhone),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _statusText(OrderStatus status) {
    return switch (status) {
      OrderStatus.outForDelivery => 'The order is on its way to you'.tr,
      OrderStatus.readyForPickup => 'Order is ready for pickup'.tr,
      OrderStatus.processing => 'Order is being prepared'.tr,
      OrderStatus.confirmed => 'Order confirmed'.tr,
      OrderStatus.pending => 'Waiting for confirmation'.tr,
      OrderStatus.delivered => 'Order delivered'.tr,
      OrderStatus.cancelled => 'Order cancelled'.tr,
      OrderStatus.rejected => 'Order rejected'.tr,
      OrderStatus.refunded => 'Order refunded'.tr,
    };
  }
}

class _TrackingBottomPanel extends StatelessWidget {
  const _TrackingBottomPanel({
    required this.details,
    required this.partnerName,
    required this.partnerId,
    required this.statusText,
    required this.onCall,
  });

  final OrderDetailsEntity details;
  final String partnerName;
  final int partnerId;
  final String statusText;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final hasDriver = partnerName.isNotEmpty || partnerId > 0;
    final phone = details.deliveryPartnerPhone?.trim() ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(66),
            border: Border.all(color: const Color(0xFFF9F9F9)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD6D6D6).withAlpha(180),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                statusText,
                style: AppFont.font14W500Black.copyWith(
                  color: const Color(0xFF666666),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Gap(8),
              Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        const Gap(12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
          decoration: BoxDecoration(
            gradient: AppColor.defaultPrimaryGradient,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Order number #@id'
                    .trParams({'id': details.orderId}),
                style: AppFont.font14W600White.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              if (hasDriver) ...[
                const Gap(12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (phone.isNotEmpty) ...[
                            _RoundActionButton(
                              icon: Icons.phone_rounded,
                              onTap: onCall,
                            ),
                            const Gap(8),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  partnerName.isNotEmpty
                                      ? partnerName
                                      : 'Delivery partner'.tr,
                                  style: AppFont.font16W600Black,
                                  textAlign: TextAlign.end,
                                ),
                                if (details.deliveryPartnerRating > 0) ...[
                                  const Gap(4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: List.generate(5, (index) {
                                      final filled = index <
                                          details.deliveryPartnerRating.round();
                                      return Icon(
                                        filled
                                            ? Icons.star_rounded
                                            : Icons.star_border_rounded,
                                        size: 16,
                                        color: const Color(0xFFFFB800),
                                      );
                                    }),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Gap(10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: SizedBox(
                              width: 52,
                              height: 52,
                              child: (details.deliveryPartnerImage ?? '')
                                      .trim()
                                      .isEmpty
                                  ? Container(
                                      color: AppColor.primaryDark,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.person_rounded,
                                        color: AppColor.primary,
                                      ),
                                    )
                                  : ImageOrSvg(
                                      details.deliveryPartnerImage!,
                                      width: 52,
                                      height: 52,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(14),
                      _MiniRouteProgress(
                        pickupLabel: details.pickupTitle.isNotEmpty
                            ? details.pickupTitle
                            : 'Pickup'.tr,
                        destinationLabel: details.destinationTitle.isNotEmpty
                            ? details.destinationTitle
                            : 'Destination'.tr,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.primaryDark,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: AppColor.primary, size: 20),
        ),
      ),
    );
  }
}

class _MiniRouteProgress extends StatefulWidget {
  const _MiniRouteProgress({
    required this.pickupLabel,
    required this.destinationLabel,
  });

  final String pickupLabel;
  final String destinationLabel;

  @override
  State<_MiniRouteProgress> createState() => _MiniRouteProgressState();
}

class _MiniRouteProgressState extends State<_MiniRouteProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.navigation_rounded,
              size: 16,
              color: AppColor.primary,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _DashedLinePainter(
                        color: AppColor.primary,
                        phase: _controller.value,
                      ),
                      child: const SizedBox(height: 2),
                    );
                  },
                ),
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColor.primary,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _DashedLinePainter(
                        color: AppColor.primary,
                        phase: _controller.value,
                      ),
                      child: const SizedBox(height: 2),
                    );
                  },
                ),
              ),
            ),
            const Icon(
              Icons.location_on_rounded,
              size: 18,
              color: AppColor.primary,
            ),
          ],
        ),
        const Gap(6),
        Row(
          children: [
            Expanded(
              child: Text(
                widget.pickupLabel,
                style: AppFont.font12w400Black.copyWith(
                  color: const Color(0xFF666666),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Text(
                widget.destinationLabel,
                style: AppFont.font12w400Black.copyWith(
                  color: const Color(0xFF666666),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({
    required this.color,
    this.phase = 0,
  });

  final Color color;
  /// 0..1 animation progress; shifts dashes toward the destination.
  final double phase;

  static const _dashWidth = 5.0;
  static const _dashSpace = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final period = _dashWidth + _dashSpace;
    final offset = phase * period;
    var startX = -period + offset;
    final y = size.height / 2;

    while (startX < size.width) {
      final from = math.max(startX, 0.0);
      final to = math.min(startX + _dashWidth, size.width);
      if (to > from) {
        canvas.drawLine(Offset(from, y), Offset(to, y), paint);
      }
      startX += period;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.phase != phase;
}
