import 'package:heraj/config/api_path.dart';
import 'package:heraj/core/models/paginated_response.dart';
import 'package:heraj/core/service/webservice/dio_helper.dart';

import '../models/vendor_model.dart';
import '../models/vendor_type_model.dart';

abstract class VendorDataSource {
  Future<List<VendorTypeModel>> getVendorTypes();

  Future<PaginatedResponse<VendorModel>> getVendors({
    int? vendorTypeId,
    int? categoryId,
    String? search,
    bool isFeatured = false,
    bool offers = false,
    double? latitude,
    double? longitude,
    int? zoneId,
    int page = 1,
    int perPage = 20,
  });
}

class VendorDataSourceImpl extends VendorDataSource {
  final ApiService apiService;

  VendorDataSourceImpl({required this.apiService});

  @override
  Future<List<VendorTypeModel>> getVendorTypes() async {
    final res = await apiService.get(
      url: ApiPath.getVendorTypes,
      returnDataOnly: true,
    );

    final list = res is List ? res : <dynamic>[];
    final types = list
        .whereType<Map>()
        .map((e) => VendorTypeModel.fromJson(Map<String, dynamic>.from(e)))
        .where((type) => type.isActive)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return types;
  }

  @override
  Future<PaginatedResponse<VendorModel>> getVendors({
    int? vendorTypeId,
    int? categoryId,
    String? search,
    bool isFeatured = false,
    bool offers = false,
    double? latitude,
    double? longitude,
    int? zoneId,
    int page = 1,
    int perPage = 20,
  }) async {
    final res = await apiService.get(
      url: ApiPath.getVendorsList(
        vendorTypeId: vendorTypeId,
        categoryId: categoryId,
        search: search,
        isFeatured: isFeatured,
        offers: offers,
        latitude: latitude,
        longitude: longitude,
        zoneId: zoneId,
        page: page,
        perPage: perPage,
      ),
      returnDataOnly: false,
    );

    final paginated = parsePaginatedResponse(
      res,
      (json) => VendorModel.fromJson(json),
    );
    final sorted = [...paginated.data]
      ..sort((a, b) => a.listingPosition.compareTo(b.listingPosition));
    return PaginatedResponse(data: sorted, meta: paginated.meta);
  }
}
