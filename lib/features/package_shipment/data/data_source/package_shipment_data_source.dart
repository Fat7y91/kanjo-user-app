import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../../../config/api_path.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../../domain/entities/package_price_quote_entity.dart';
import '../../domain/entities/package_shipment_entity.dart';
import '../../domain/entities/package_shipment_params.dart';
import '../../domain/entities/package_size_entity.dart';

abstract class PackageShipmentDataSource {
  Future<List<PackageSizeEntity>> getPackageSizes();

  Future<PackagePriceQuoteEntity> calculatePrice(
    CalculatePackagePriceParams params,
  );

  Future<PackageShipmentEntity> createShipment(
    CreatePackageShipmentParams params,
  );

  Future<PackageShipmentEntity> getShipmentDetails(String shipmentId);

  Future<PaginatedResponse<PackageShipmentEntity>> getMyShipments({
    int page = 1,
    int perPage = 15,
  });

  Future<bool> cancelShipment(String shipmentId);
}

class PackageShipmentDataSourceImpl extends PackageShipmentDataSource {
  PackageShipmentDataSourceImpl({required this.apiService});

  final ApiService apiService;

  @override
  Future<List<PackageSizeEntity>> getPackageSizes() async {
    final res = await apiService.get(
      url: ApiPath.packageSizes,
      returnDataOnly: true,
    );
    if (res is! List) return const [];
    return res
        .whereType<Map>()
        .map((e) => PackageSizeEntity.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => e.isActive)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Future<PackagePriceQuoteEntity> calculatePrice(
    CalculatePackagePriceParams params,
  ) async {
    final res = await apiService.post(
      url: ApiPath.calculatePackageShipmentPrice,
      requestBody: FormData.fromMap(params.toFormMap()),
      returnDataOnly: true,
    );
    if (res is Map) {
      return PackagePriceQuoteEntity.fromJson(Map<String, dynamic>.from(res));
    }
    return PackagePriceQuoteEntity.fromJson(const <String, dynamic>{});
  }

  @override
  Future<PackageShipmentEntity> createShipment(
    CreatePackageShipmentParams params,
  ) async {
    final map = <String, dynamic>{
      'package_size_id': params.packageSizeId.toString(),
      'pickup_lat': params.pickupLat.toString(),
      'pickup_lng': params.pickupLng.toString(),
      'payment_method': params.paymentMethod,
    };
    for (var i = 0; i < params.dropoffs.length; i++) {
      final d = params.dropoffs[i];
      map['dropoffs[$i][receiver_name]'] = d.receiverName.trim();
      map['dropoffs[$i][receiver_phone]'] = d.receiverPhone.trim();
      map['dropoffs[$i][dropoff_lat]'] = d.dropoffLat.toString();
      map['dropoffs[$i][dropoff_lng]'] = d.dropoffLng.toString();
      map['dropoffs[$i][address_details]'] = d.dropoffAddress.trim();
    }
    final image = params.packageImage;
    if (image != null) {
      map['package_image'] = await MultipartFile.fromFile(
        image.path,
        filename: p.basename(image.path),
      );
    }

    final res = await apiService.post(
      url: ApiPath.packageShipments,
      requestBody: FormData.fromMap(map),
      returnDataOnly: true,
    );
    if (res is Map) {
      return PackageShipmentEntity.fromJson(Map<String, dynamic>.from(res));
    }
    return PackageShipmentEntity.fromJson(const <String, dynamic>{});
  }

  @override
  Future<PackageShipmentEntity> getShipmentDetails(String shipmentId) async {
    final res = await apiService.get(
      url: ApiPath.packageShipment(shipmentId),
      returnDataOnly: true,
    );
    if (res is Map) {
      return PackageShipmentEntity.fromJson(Map<String, dynamic>.from(res));
    }
    return PackageShipmentEntity.fromJson(const <String, dynamic>{});
  }

  @override
  Future<PaginatedResponse<PackageShipmentEntity>> getMyShipments({
    int page = 1,
    int perPage = 15,
  }) async {
    final res = await apiService.get(
      url: ApiPath.packageShipments,
      returnDataOnly: false,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );
    return parsePaginatedResponse(res, PackageShipmentEntity.fromJson);
  }

  @override
  Future<bool> cancelShipment(String shipmentId) async {
    await apiService.post(
      url: ApiPath.cancelPackageShipment(shipmentId),
      returnDataOnly: true,
    );
    return true;
  }
}
