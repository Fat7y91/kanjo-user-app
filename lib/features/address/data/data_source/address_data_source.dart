import '../../../../config/api_path.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../model/address_model.dart';

abstract class AddressDataSource {
  Future<AddressModel> addAddress({required Map<String, dynamic> map});

  Future<bool> updateAddress({
    required String addressId,
    required Map<String, dynamic> map,
  });

  Future<bool> deleteAddress({required String addressId});

  Future<bool> setDefaultAddress({required String addressId});

  Future<List<AddressModel>> getAddresses();
}

class AddressDataSourceImp extends AddressDataSource {
  final ApiService apiService;

  AddressDataSourceImp({required this.apiService});

  Map<String, dynamic> _bodyFromMap(Map<String, dynamic> map) {
    final body = <String, dynamic>{
      if (map['label'] != null) 'label': map['label'],
      if (map['address'] != null) 'address': map['address'],
      if (map['latitude'] != null) 'latitude': map['latitude'],
      if (map['longitude'] != null) 'longitude': map['longitude'],
      if (map['is_default'] != null || map['isDefault'] != null)
        'is_default': map['is_default'] ?? map['isDefault'],
    };

    final coordinates = map['coordinates'];
    if (coordinates is List && coordinates.length >= 2) {
      body['longitude'] ??= coordinates[0];
      body['latitude'] ??= coordinates[1];
    }

    body.removeWhere(
      (key, value) => value == null || (value is String && value.isEmpty),
    );
    return body;
  }

  @override
  Future<AddressModel> addAddress({required Map<String, dynamic> map}) async {
    final res = await apiService.post(
      url: ApiPath.addAddress,
      requestBody: _bodyFromMap(map),
      returnDataOnly: true,
    );

    if (res is Map) {
      return AddressModel.fromJson(Map<String, dynamic>.from(res));
    }
    return AddressModel(
      id: '',
      label: map['label']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      isDefault: map['is_default'] == true || map['isDefault'] == true,
    );
  }

  @override
  Future<bool> updateAddress({
    required String addressId,
    required Map<String, dynamic> map,
  }) async {
    await apiService.put(
      url: '${ApiPath.updateAddress}/$addressId',
      requestBody: _bodyFromMap(map),
      returnDataOnly: true,
    );
    return true;
  }

  @override
  Future<bool> deleteAddress({required String addressId}) async {
    await apiService.delete(url: '${ApiPath.deleteAddress}/$addressId');
    return true;
  }

  @override
  Future<bool> setDefaultAddress({required String addressId}) async {
    await apiService.post(
      url: ApiPath.setDefaultAddress(addressId),
      returnDataOnly: true,
    );
    return true;
  }

  @override
  Future<List<AddressModel>> getAddresses() async {
    return fetchAllPaginatedPages(
      fetchPage: (page) async {
        final res = await apiService.get(
          url: ApiPath.getAddressesList(
            page: page,
            perPage: PaginationConfig.largePerPage,
          ),
          returnDataOnly: false,
        );
        return parsePaginatedResponse(
          res,
          (json) => AddressModel.fromJson(json),
        );
      },
    );
  }
}
