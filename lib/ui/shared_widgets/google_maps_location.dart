// import 'dart:ui' as ui;
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
// import 'package:taiseer/ui/shared_widgets/loading_widget.dart';
//
// import '../../../config/app_font.dart';
// import '../../../config/app_string.dart';
//
// class GoogleMapsLocation extends StatefulWidget {
//   const GoogleMapsLocation({
//     super.key,
//     required this.location,
//     this.removePadding = false,
//     this.onPlacePicked,
//   });
//
//   final ValueChanged<(LatLng, String?)>? onPlacePicked;
//
//   final LatLng? location;
//   final bool removePadding;
//
//   @override
//   State<GoogleMapsLocation> createState() => _GoogleMapsLocationState();
// }
//
// class _GoogleMapsLocationState extends State<GoogleMapsLocation> {
//   GoogleMapController? mapController;
//   final String _mapStyle = '''
// [
//   {
//     "elementType": "geometry",
//     "stylers": [
//       { "color": "##e9e7e0" }
//     ]
//   },
//   {
//     "featureType": "administrative.country",
//     "elementType": "geometry.stroke",
//     "stylers": [
//       { "color": "#007AFF" }
//     ]
//   },
//   {
//     "featureType": "poi",
//     "stylers": [
//       { "visibility": "off" }
//     ]
//   },
//   {
//     "featureType": 'road',
//      'stylers': [
//        {'visibility': 'off'}
//      ]
//    },
//    {
//      'featureType': 'transit',
//      'stylers': [
//        {'visibility': 'off'}
//      ]
//    },
//    {
//      'featureType': 'landscape',
//      'stylers': [
//        {'visibility': 'off'}
//      ]
//    },
//    {
//      'featureType': 'administrative.locality',
//      'stylers': [
//        {'visibility': 'off'}
//      ]
//    },
//    {
//       'featureType': 'water',
//       'stylers': [
//         {'color': '#A4E1FF'}
//       ]
//    }
// ]
// ''';
//
//   void onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//     mapController!.setMapStyle(_mapStyle);
//   }
//
//   Future<Uint8List> getBytesFromAsset(String path, int width) async {
//     ByteData data = await rootBundle.load(path);
//     ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
//         targetWidth: width);
//     ui.FrameInfo fi = await codec.getNextFrame();
//     return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
//         .buffer
//         .asUint8List();
//   }
//
//   // getImageMarker()async{
//   //   customMarker =BitmapDescriptor.fromBytes(await getBytesFromAsset('assets/images/images/red.png', 50));
//   //   selectedMarker =BitmapDescriptor.fromBytes(await getBytesFromAsset('assets/images/images/blue.png', 50));
//   // }
//   @override
//   Widget build(BuildContext context) {
//     responsiveInit(context);
//     return Padding(
//       padding: widget.removePadding
//           ? EdgeInsets.zero
//           : EdgeInsets.symmetric(horizontal: 11.w),
//       child: SizedBox(
//         height: 234.h,
//         width: double.infinity,
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(10),
//           child: Stack(
//             children: [
//               GoogleMap(
//                 onMapCreated: onMapCreated,
//                 onLongPress: (latLng) {
//                   if (widget.onPlacePicked != null) {
//                     widget.onPlacePicked!((latLng, null));
//                   }
//                 },
//                 gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
//                   Factory<OneSequenceGestureRecognizer>(
//                     () => EagerGestureRecognizer(),
//                   ),
//                 },
//                 myLocationButtonEnabled: false,
//                 zoomGesturesEnabled: true,
//                 markers: {
//                   if (widget.location != null)
//                     Marker(
//                         markerId: MarkerId(
//                             "${widget.location!.longitude} ${widget.location!.latitude}"),
//                         position: widget.location!)
//                 },
//                 mapType: MapType.normal,
//                 initialCameraPosition: CameraPosition(
//                   target: widget.location ?? AppString.initialLatLong,
//                   zoom: 14.4746,
//                 ),
//               ),
//               if (widget.onPlacePicked != null && widget.location == null)
//                 Opacity(
//                   opacity: 0.3,
//                   child: Container(
//                     color: Colors.white,
//                     height: 234.h,
//                     width: double.infinity,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       mainAxisSize: MainAxisSize.max,
//                       children: [
//                         SvgPicture.asset(
//                           "assets/عقارك-15.svg",
//                           color: AppColor.grey2,
//                           height: 80,
//                         ),
//                         SizedBox(
//                           height: 20.h,
//                         ),
//                         CustomButton(
//                           height: 35,
//                           width: 180.w,
//                           text: "Pick Location".tr,
//                           onPressed: _pick,
//                           color: AppColor.grey2,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               if (widget.onPlacePicked != null && widget.location != null)
//                 Opacity(
//                   opacity: 0.5,
//                   child: Align(
//                     alignment: const AlignmentDirectional(0, 0.8),
//                     child: CustomButton(
//                       height: 35,
//                       width: 180.w,
//                       fontSize: 14,
//                       text: "Edit Location".tr,
//                       color: AppColor.grey2,
//                       onPressed: _pick,
//                     ),
//                   ),
//                 )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   _pick() {
//     Get.to(() => PlacePicker(
//           key: UniqueKey(),
//           hintText: 'Search a Place'.tr,
//           useCurrentLocation: true,
//           selectInitialPosition: true,
//           apiKey: AppString.googleMapsApiKey,
//           initialPosition: widget.location ?? AppString.initialLatLong,
//           onPlacePicked: (a) {
//             widget.onPlacePicked!((
//               LatLng(a.geometry!.location.lat, a.geometry!.location.lng),
//               a.formattedAddress
//             ));
//             mapController!.moveCamera(CameraUpdate.newCameraPosition(
//                 CameraPosition(
//                     target: LatLng(
//                         a.geometry!.location.lat, a.geometry!.location.lng),
//                     zoom: 14.4746)));
//             Get.back();
//           },
//         ));
//   }
// }
//
// class CustomButton extends StatelessWidget {
//   const CustomButton({
//     super.key,
//     required this.text,
//     this.iconFirst = false,
//     required this.color,
//     this.onPressed,
//     this.icon,
//     this.height = 47,
//     this.width = 167,
//     this.fontSize,
//     this.loading,
//   });
//
//   final String text;
//   final Color color;
//   final Widget? icon;
//   final bool iconFirst;
//   final double? fontSize;
//   final double height;
//   final double width;
//   final void Function()? onPressed;
//   final bool? loading;
//
//   @override
//   Widget build(BuildContext context) {
//     responsiveInit(context);
//     return InkWell(
//       onTap: loading == true ? null : onPressed,
//       child: Container(
//         height: height.h,
//         width: width.w,
//         decoration: BoxDecoration(
//           color: loading == true ? null : color,
//           borderRadius: BorderRadius.circular(5),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.16),
//               blurRadius: 6,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: loading == true
//             ? const Center(
//                 child: LoadingWidget(),
//               )
//             : icon == null
//                 ? Center(
//                     child: Text(
//                     text,
//                     style: AppFont.buttonText.copyWith(fontSize: fontSize),
//                   ))
//                 : iconFirst
//                     ? Row(
//                         children: [
//                           Expanded(child: icon!),
//                           Text(
//                             text,
//                             style:
//                                 AppFont.buttonText.copyWith(fontSize: fontSize),
//                           ),
//                           const Expanded(child: SizedBox()),
//                         ],
//                       )
//                     : Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             text,
//                             style:
//                                 AppFont.buttonText.copyWith(fontSize: fontSize),
//                           ),
//                           const SizedBox(
//                             width: 6,
//                           ),
//                           icon!
//                         ],
//                       ),
//       ),
//     );
//   }
// }
