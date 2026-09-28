import 'package:dio/dio.dart';
import '../../../../config/api_path.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../../domain/entities/rating_params_entity.dart';

abstract class RatingDataSource {
  Future<bool> rateVendor(RatingParamsEntity params);

  Future<bool> rateDeliveryPartner(RatingParamsEntity params);
}

class RatingDataSourceImpl extends RatingDataSource {
  RatingDataSourceImpl({required this.apiService});

  final ApiService apiService;

  @override
  Future<bool> rateVendor(RatingParamsEntity params) async {
    await apiService.post(
      url: ApiPath.rateVendor(params.targetId),
      requestBody: _ratingFormData(params),
      returnDataOnly: true,
    );
    return true;
  }

  @override
  Future<bool> rateDeliveryPartner(RatingParamsEntity params) async {
    await apiService.post(
      url: ApiPath.rateDeliveryPartner(params.targetId),
      requestBody: _ratingFormData(params),
      returnDataOnly: true,
    );
    return true;
  }

  FormData _ratingFormData(RatingParamsEntity params) {
    return FormData.fromMap({
      'rating': params.rating.toString(),
      'comment': params.comment,
    });
  }
}
