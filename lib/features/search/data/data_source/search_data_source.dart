import '../models/app_search_result_model.dart';

abstract class SearchDataSource {
  Future<AppSearchResultModel> search(String query);
}
