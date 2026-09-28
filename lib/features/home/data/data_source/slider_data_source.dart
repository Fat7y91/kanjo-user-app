import 'package:heraj/config/api_path.dart';
import 'package:heraj/core/service/webservice/dio_helper.dart';
import '../models/slider_model.dart';
import '../models/sliders_list_model.dart';

abstract class SliderDataSource {
  Future<List<SliderModel>> getSliders({
    double? latitude,
    double? longitude,
    int? zoneId,
  });
}

class SliderDataSourceImp extends SliderDataSource {
  final ApiService apiService;

  SliderDataSourceImp({required this.apiService});

  @override
  Future<List<SliderModel>> getSliders({
    double? latitude,
    double? longitude,
    int? zoneId,
  }) async {
    final res = await apiService.get(
      url: ApiPath.getSlidersList(
        latitude: latitude,
        longitude: longitude,
        zoneId: zoneId,
      ),
      returnDataOnly: true,
    );

    if (res is Map) {
      return SlidersListModel.fromJson(Map<String, dynamic>.from(res)).data;
    }
    if (res is List) {
      return res
          .whereType<Map>()
          .map((item) => SliderModel.fromJson(Map<String, dynamic>.from(item)))
          .where((slider) => slider.imageUrl.isNotEmpty)
          .toList();
    }
    return const [];
  }
}
