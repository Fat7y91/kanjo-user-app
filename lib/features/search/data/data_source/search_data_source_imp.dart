import 'package:heraj/config/api_path.dart';
import 'package:heraj/core/service/webservice/dio_helper.dart';
import 'package:heraj/features/search/data/data_source/search_data_source.dart';
import 'package:heraj/features/search/data/models/app_search_result_model.dart';

class SearchDataSourceImpl extends SearchDataSource {
  SearchDataSourceImpl({required this.apiService});

  final ApiService apiService;

  @override
  Future<AppSearchResultModel> search(String query) async {
    final res = await apiService.get(
      url: ApiPath.search(query),
      returnDataOnly: true,
    );
    return AppSearchResultModel.fromJson(
      Map<String, dynamic>.from(res as Map),
    );
  }
}
