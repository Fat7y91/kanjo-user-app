import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/utils/map_marker_icons.dart';
import 'package:heraj/features/orders/domain/entities/order_entity.dart';
import 'package:heraj/features/orders/domain/entities/order_geo_point.dart';
import 'package:heraj/features/orders/presentation/managers/order_tracking_location_provider.dart';
import 'package:heraj/features/orders/presentation/view/widgets/order_status_stepper.dart';
import 'package:heraj/features/orders/presentation/view/widgets/order_tracking_map_overlay.dart';
import 'package:lottie/lottie.dart' hide Marker;
import '../../../domain/entities/order_details_entity.dart';

class OrderEtaCard extends StatelessWidget {
  const OrderEtaCard({
    super.key,
    required this.entity,
    required this.showTrack,
    required this.onTrack,
    this.isHome = false,
    required this.onPlay,
  });

  final OrderDetailsEntity entity;
  final bool showTrack;
  final bool isHome;
  final VoidCallback onTrack;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final showHomeMap =
        isHome && entity.status == OrderStatus.outForDelivery;

    return Container(
      decoration: BoxDecoration(
        gradient: AppColor.defaultPrimaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          if (showHomeMap) ...[
            _HomeOutForDeliveryMap(entity: entity),
            const Gap(10),
          ],
          OrderStatusStepper(
            status: entity.status,
            onGradient: true,
          ),
          if (!isHome) const Gap(4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _OrderStatusVisual(status: entity.status),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isHome)
                    Text(
                      '${entity.destinationAddress}${entity.deliveryPartnerName.isNotEmpty ? ' - ' : ''}${entity.deliveryPartnerName}',
                      style: AppFont.font14W500Black.copyWith(
                        color: const Color(0xFFF2F2F2),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  Text(
                    entity.isScheduledOrder
                        ? 'Scheduled order'.tr
                        : 'Estimated arrival time'.tr,
                    style: AppFont.font14W500Black.copyWith(
                      color: const Color(0xFFF2F2F2),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (!isHome) const Gap(8),
                  Row(
                    children: [
                      Text(
                        _arrivalText(context),
                        style: AppFont.font24w600Black.copyWith(
                          color: Colors.white,
                          fontSize: entity.isScheduledOrder ? 14 : 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isHome) ...[
                        Text(
                          entity.totalAmount.isEqual(0.0)
                              ? '--'
                              : " - ${entity.totalAmount.toInt()} L.E",
                          style: AppFont.font24w600Black.copyWith(
                            color: Colors.white,
                            fontSize: entity.isScheduledOrder ? 14 : 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ],
          ),
          if (entity.status != OrderStatus.rejected) ...[
            const Gap(6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (showTrack)
                  InkWell(
                    onTap: onTrack,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFAE77),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Track order'.tr,
                        style: AppFont.font14W500Black.copyWith(
                          color: const Color(0xFF111111),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                InkWell(
                  onTap: onPlay,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Enjoy your time'.tr,
                          style: AppFont.font14W500White.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Gap(8),
                        SvgPicture.asset(
                          AppAssets.bag,
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _arrivalText(BuildContext context) {
    if (entity.isScheduledOrder && entity.scheduledDeliveryAt != null) {
      final locale = Get.locale?.languageCode ??
          Localizations.localeOf(context).languageCode;
      return formatOrderScheduledDeliveryAt(
        entity.scheduledDeliveryAt!,
        locale: locale,
      );
    }
    if (entity.isScheduledOrder) return 'Scheduled order'.tr;
    return entity.etaText.isEmpty ? '--' : entity.etaText;
  }
}

class _HomeOutForDeliveryMap extends ConsumerStatefulWidget {
  const _HomeOutForDeliveryMap({required this.entity});

  final OrderDetailsEntity entity;

  @override
  ConsumerState<_HomeOutForDeliveryMap> createState() =>
      _HomeOutForDeliveryMapState();
}

class _HomeOutForDeliveryMapState
    extends ConsumerState<_HomeOutForDeliveryMap> {
  static const _fallback = LatLng(30.0444, 31.2357);

  GoogleMapController? _mapController;
  BitmapDescriptor? _driverMarkerIcon;
  LatLng? _lastCameraTarget;
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
        const ImageConfiguration(size: Size(64, 64)),
        AppAssets.kanjoDelivery,
      );
      if (!mounted) return;
      setState(() => _driverMarkerIcon = icon);
    } catch (_) {}
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  bool _samePoint(LatLng a, LatLng b) =>
      (a.latitude - b.latitude).abs() < 0.00001 &&
      (a.longitude - b.longitude).abs() < 0.00001;

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
      if (_lastCameraTarget != null && _samePoint(_lastCameraTarget!, target)) {
        return;
      }
      _lastCameraTarget = target;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 14.5),
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

    _lastCameraTarget = LatLng(
      (minLat + maxLat) / 2,
      (minLng + maxLng) / 2,
    );
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        48,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.entity.orderId;
    final liveAsync = ref.watch(orderTrackingLocationProvider(orderId));
    final live = liveAsync.valueOrNull;
    final driverPoint = live?.location ?? widget.entity.driverLocation;
    final destination = widget.entity.destinationLocation;
    final pickup = widget.entity.pickupLocation;
    final routeOrigin = driverPoint ?? pickup;
    final initialTarget = driverPoint ??
        destination ??
        pickup ??
        OrderGeoPoint(
          latitude: _fallback.latitude,
          longitude: _fallback.longitude,
        );

    ref.listen(orderTrackingLocationProvider(orderId), (previous, next) {
      final update = next.valueOrNull;
      if (update == null) return;
      _loadRoute(origin: update.location, destination: destination);
      _fitCamera(
        pickup: pickup,
        destination: destination,
        driver: update.location,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadRoute(origin: routeOrigin, destination: destination);
    });

    final markers = OrderTrackingMapOverlay.markers(
      destination: destination,
      driver: driverPoint,
      pickup: pickup,
      driverIcon: _driverMarkerIcon,
      destinationTitle: widget.entity.destinationTitle.isNotEmpty
          ? widget.entity.destinationTitle
          : (widget.entity.destinationAddress.isNotEmpty
              ? widget.entity.destinationAddress
              : 'Destination'.tr),
      pickupTitle: widget.entity.pickupTitle.isNotEmpty
          ? widget.entity.pickupTitle
          : 'Pickup'.tr,
      driverTitle: widget.entity.deliveryPartnerName.isNotEmpty
          ? widget.entity.deliveryPartnerName
          : 'Delivery partner'.tr,
    );

    final polylines = OrderTrackingMapOverlay.polylines(
      driver: driverPoint,
      destination: destination,
      pickup: pickup,
      routePoints: _routePoints,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 160,
        width: double.infinity,
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
          markers: markers,
          polylines: polylines,
          // Lite mode reliably paints polylines inside scrollable home lists.
          liteModeEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
          scrollGesturesEnabled: false,
          zoomGesturesEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
        ),
      ),
    );
  }
}

class _OrderStatusVisual extends StatelessWidget {
  const _OrderStatusVisual({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.delivered) {
      return Lottie.asset(
        AppAssets.successLottie,
        width: 80,
        height: 80,
        repeat: true,
        fit: BoxFit.contain,
      );
    }
    if (status == OrderStatus.rejected) {
      return const _RejectedOrderIcon();
    }
    return Lottie.asset(
      AppAssets.sandClock,
      width: 80,
      height: 80,
      repeat: true,
      fit: BoxFit.contain,
    );
  }
}

class _RejectedOrderIcon extends StatefulWidget {
  const _RejectedOrderIcon();

  @override
  State<_RejectedOrderIcon> createState() => _RejectedOrderIconState();
}

class _RejectedOrderIconState extends State<_RejectedOrderIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _ringOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _ringOpacity = Tween<double>(begin: 0.18, end: 0.42).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white
                      .withAlpha((255 * _ringOpacity.value).round()),
                ),
              ),
              Transform.scale(
                scale: _scale.value,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFB42318),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
