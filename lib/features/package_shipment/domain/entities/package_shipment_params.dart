import 'dart:io';

import 'package_dropoff_input.dart';

class CalculatePackagePriceParams {
  const CalculatePackagePriceParams({
    required this.packageSizeId,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffs,
  });

  final int packageSizeId;
  final double pickupLat;
  final double pickupLng;
  final List<PackageDropoffInput> dropoffs;

  Map<String, dynamic> toFormMap() {
    final map = <String, dynamic>{
      'package_size_id': packageSizeId.toString(),
      'pickup_lat': pickupLat.toString(),
      'pickup_lng': pickupLng.toString(),
    };
    for (var i = 0; i < dropoffs.length; i++) {
      final d = dropoffs[i];
      map['dropoffs[$i][dropoff_lat]'] = d.dropoffLat.toString();
      map['dropoffs[$i][dropoff_lng]'] = d.dropoffLng.toString();
    }
    return map;
  }
}

class CreatePackageShipmentParams {
  const CreatePackageShipmentParams({
    required this.packageSizeId,
    required this.pickupLat,
    required this.pickupLng,
    required this.paymentMethod,
    required this.dropoffs,
    this.packageImage,
  });

  final int packageSizeId;
  final double pickupLat;
  final double pickupLng;
  final String paymentMethod;
  final List<PackageDropoffInput> dropoffs;
  final File? packageImage;

  Future<Map<String, dynamic>> toFormMap() async {
    final map = <String, dynamic>{
      'package_size_id': packageSizeId.toString(),
      'pickup_lat': pickupLat.toString(),
      'pickup_lng': pickupLng.toString(),
      'payment_method': paymentMethod,
    };
    for (var i = 0; i < dropoffs.length; i++) {
      final d = dropoffs[i];
      map['dropoffs[$i][receiver_name]'] = d.receiverName.trim();
      map['dropoffs[$i][receiver_phone]'] = d.receiverPhone.trim();
      map['dropoffs[$i][dropoff_lat]'] = d.dropoffLat.toString();
      map['dropoffs[$i][dropoff_lng]'] = d.dropoffLng.toString();
      map['dropoffs[$i][address_details]'] = d.dropoffAddress.trim();
    }
    final image = packageImage;
    if (image != null) {
      // MultipartFile filled in data source
      map['package_image_path'] = image.path;
    }
    return map;
  }
}
