import '../../../../config/api_path.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../models/offer_model.dart';
import '../models/offers_list_model.dart';

abstract class OffersDataSource {
  Future<List<OfferModel>> getOffers({
    double? latitude,
    double? longitude,
    int? zoneId,
  });
}

class OffersDataSourceImpl extends OffersDataSource {
  OffersDataSourceImpl({required this.apiService});

  final ApiService apiService;

  @override
  Future<List<OfferModel>> getOffers({
    double? latitude,
    double? longitude,
    int? zoneId,
  }) async {
    final res = await apiService.get(
      url: ApiPath.getOffersList(
        latitude: latitude,
        longitude: longitude,
        zoneId: zoneId,
      ),
      returnDataOnly: true,
    );

    if (res is Map) {
      return OffersListModel.fromJson(Map<String, dynamic>.from(res)).data;
    }
    if (res is List) {
      return res
          .whereType<Map>()
          .map((e) => OfferModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }
}
