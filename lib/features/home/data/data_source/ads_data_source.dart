import 'package:dio/dio.dart';
import 'package:heraj/config/api_path.dart';
import 'package:heraj/core/service/webservice/dio_helper.dart';
import '../../domain/entities/ad_entity.dart';

abstract class AdsDataSource {
  Future<List<AdEntity>> getBanners();
}

class AdsDataSourceImp extends AdsDataSource {
  final ApiService apiService;

  AdsDataSourceImp({required this.apiService});
  @override
  Future<List<AdEntity>> getBanners() async {
    await Future.delayed(Duration(seconds: 1));
    return dummyAds;
    // final res =
    //     await apiService.get(url: ApiPath.getHomeSliders, returnDataOnly: true);
    // final slidersList = res['sliders'] as List<dynamic>? ?? [];
    // return slidersList
    //     .map((item) =>
    //         AdEntity.fromJson(item is Map<String, dynamic> ? item : null))
    //     .where((item) => item.isActive)
    //     .toList()
    //   ..sort((a, b) => a.order.compareTo(b.order));
  }
}
