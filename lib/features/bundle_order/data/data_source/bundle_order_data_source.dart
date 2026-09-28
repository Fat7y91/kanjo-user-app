import '../../../../config/api_path.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../../domain/entities/submit_bundle_params.dart';
import '../models/bundle_order_model.dart';

abstract class BundleOrderDataSource {
  Future<List<BundleOrderModel>> listMyBundleOrders();

  Future<BundleOrderModel> createBundleFromCart({String? notes});

  Future<BundleOrderModel> showBundleByCode(String code);

  Future<BundleOrderModel> addMyCartToBundle(String code);

  Future<bool> removeMyBundleItem({
    required String bundleCode,
    required int bundleItemId,
  });

  Future<bool> cancelBundleOrder(String code);

  Future<BundleOrderModel> submitBundle(SubmitBundleParams params);
}

class BundleOrderDataSourceImpl extends BundleOrderDataSource {
  final ApiService apiService;

  BundleOrderDataSourceImpl({required this.apiService});

  BundleOrderModel _parseBundle(dynamic res) {
    if (res is Map) {
      return BundleOrderModel.fromJson(Map<String, dynamic>.from(res));
    }
    return const BundleOrderModel(
      id: 0,
      code: '',
      status: '',
      isHost: false,
    );
  }

  @override
  Future<List<BundleOrderModel>> listMyBundleOrders() async {
    final res = await apiService.get(
      url: ApiPath.bundleOrders,
      returnDataOnly: true,
    );
    final parsed = parsePaginatedResponse(
      res,
      (json) => BundleOrderModel.fromJson(json),
    );
    return parsed.data;
  }

  @override
  Future<BundleOrderModel> createBundleFromCart({String? notes}) async {
    final body = <String, dynamic>{};
    final trimmedNotes = notes?.trim();
    if (trimmedNotes != null && trimmedNotes.isNotEmpty) {
      body['notes'] = trimmedNotes;
    }

    final res = await apiService.post(
      url: ApiPath.bundleOrders,
      requestBody: body,
      returnDataOnly: true,
    );
    return _parseBundle(res);
  }

  @override
  Future<BundleOrderModel> showBundleByCode(String code) async {
    final res = await apiService.get(
      url: ApiPath.showBundleByCode(code),
      returnDataOnly: true,
    );
    return _parseBundle(res);
  }

  @override
  Future<BundleOrderModel> addMyCartToBundle(String code) async {
    final res = await apiService.post(
      url: ApiPath.addMyCartToBundle(code),
      requestBody: <String, dynamic>{},
      returnDataOnly: true,
    );
    return _parseBundle(res);
  }

  @override
  Future<bool> removeMyBundleItem({
    required String bundleCode,
    required int bundleItemId,
  }) async {
    await apiService.delete(
      url: ApiPath.removeBundleItem(bundleCode, bundleItemId),
    );
    return true;
  }

  @override
  Future<bool> cancelBundleOrder(String code) async {
    await apiService.post(
      url: ApiPath.cancelBundleOrder(code),
      requestBody: <String, dynamic>{},
      returnDataOnly: true,
    );
    return true;
  }

  @override
  Future<BundleOrderModel> submitBundle(SubmitBundleParams params) async {
    final res = await apiService.post(
      url: ApiPath.submitBundle(params.code),
      requestBody: params.toJson(),
      returnDataOnly: true,
    );
    return _parseBundle(res);
  }
}
