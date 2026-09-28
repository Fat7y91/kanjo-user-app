import '../../../../config/api_path.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../models/category_model.dart';

abstract class CategoriesDataSource {
  Future<List<CategoryModel>> getCategoriesByVendorType(int vendorTypeId);
}

class CategoriesDataSourceImpl extends CategoriesDataSource {
  final ApiService apiService;

  CategoriesDataSourceImpl({required this.apiService});

  @override
  Future<List<CategoryModel>> getCategoriesByVendorType(
      int vendorTypeId) async {
    final categories = await fetchAllPaginatedPages(
      fetchPage: (page) async {
        final res = await apiService.get(
          url: ApiPath.getCategoriesByVendorType(
            vendorTypeId,
            page: page,
            perPage: PaginationConfig.largePerPage,
          ),
          returnDataOnly: false,
        );
        return parsePaginatedResponse(
          res,
          (json) => CategoryModel.fromJson(json),
        );
      },
    );

    return categories.where((c) => c.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}
