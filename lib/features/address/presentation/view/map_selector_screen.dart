import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/location_service/location_service.dart';
import 'package:heraj/main.dart';

class MapSelectorScreen extends StatefulWidget {
  const MapSelectorScreen({
    super.key,
    this.initialCoordinates,
  });

  final List<double>? initialCoordinates;

  @override
  State<MapSelectorScreen> createState() => _MapSelectorScreenState();
}

class _MapSelectorScreenState extends State<MapSelectorScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  final LocationService _locationService = getIt<LocationService>();
  late AnimationController _backgroundAnimationController;
  late AnimationController _pinAnimationController;
  late Animation<double> _pinScaleAnimation;

  static const LatLng cairoLatLng = LatLng(30.0444, 31.2357);

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
    _pinAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pinScaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _pinAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.initialCoordinates != null &&
        widget.initialCoordinates!.length >= 2) {
      _selectedLocation = LatLng(
        widget.initialCoordinates![1],
        widget.initialCoordinates![0],
      );
    } else {
      _selectedLocation = cairoLatLng;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedLocation != null && mounted) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_selectedLocation!, 14.0),
        );
      }
    });
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  void _onCameraIdle() {
    if (_mapController != null && mounted) {
      _mapController!.getVisibleRegion().then((bounds) {
        if (mounted) {
          final center = LatLng(
            (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
            (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
          );
          setState(() {
            _selectedLocation = center;
          });
        }
      }).catchError((error) {
        // Handle error silently
      });
    }
  }

  void _onCurrentLocationPressed() async {
    final currentLocation = await _locationService.getCurrentLocation();
    if (currentLocation != null) {
      final latLng = LatLng(
        currentLocation.latitude,
        currentLocation.longitude,
      );
      setState(() {
        _selectedLocation = latLng;
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 14.0),
      );
    } else {
      Get.snackbar(
        "Error".tr,
        "Unable to get current location".tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _onConfirm() {
    if (_selectedLocation != null) {
      final coordinates = [
        _selectedLocation!.longitude,
        _selectedLocation!.latitude
      ];
      Get.back(result: coordinates);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _backgroundAnimationController.dispose();
    _pinAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            onCameraIdle: _onCameraIdle,
            onTap: (LatLng position) => _onMapTap(position),
            initialCameraPosition: CameraPosition(
              target: _selectedLocation ?? cairoLatLng,
              zoom: 14.0,
            ),
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            rotateGesturesEnabled: true,
            compassEnabled: true,
            liteModeEnabled: false,
          ),
          // Custom AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColor.white.withAlpha(240),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: AppColor.black,
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        "Select Location".tr,
                        style: AppFont.font18W700Black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Center Pin
          Center(
            child: IgnorePointer(
              ignoring: true,
              child: AnimatedBuilder(
                animation: _pinScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pinScaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColor.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.primary.withAlpha(100),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColor.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          // Current Location Button
          PositionedDirectional(
            bottom: MediaQuery.of(context).padding.bottom + 100,
            end: 16,
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _onCurrentLocationPressed,
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      Icons.my_location_rounded,
                      color: AppColor.primary,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Confirm Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                left: 16,
                right: 16,
                top: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withAlpha(0),
                    Colors.white,
                    Colors.white,
                  ],
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.primary,
                      AppColor.primaryDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primary.withAlpha(80),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _onConfirm,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          const Gap(12),
                          Text(
                            "Confirm Location".tr,
                            style: AppFont.font18W700Black.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
