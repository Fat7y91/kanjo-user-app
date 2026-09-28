import '../../../../config/api_path.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../models/product_model.dart';

abstract class ProductsDataSource {
  Future<PaginatedResponse<ProductModel>> searchProducts(
    String query, {
    int? vendorId,
    int page = 1,
    int perPage = 20,
  });

  Future<PaginatedResponse<ProductModel>> getProducts({
    required int vendorId,
    int? categoryId,
    int page = 1,
    int perPage = 20,
  });

  Future<ProductModel> getProductDetails(int productId);
}

class ProductsDataSourceImpl extends ProductsDataSource {
  final ApiService apiService;

  ProductsDataSourceImpl({required this.apiService});

  @override
  Future<PaginatedResponse<ProductModel>> searchProducts(
    String query, {
    int? vendorId,
    int page = 1,
    int perPage = 20,
  }) async {
    final res = await apiService.get(
      url: ApiPath.searchProducts(
        query,
        vendorId: vendorId,
        page: page,
        perPage: perPage,
      ),
      returnDataOnly: false,
    );

    return parsePaginatedResponse(
      res,
      (json) => ProductModel.fromJson(json),
    );
  }

  @override
  Future<PaginatedResponse<ProductModel>> getProducts({
    required int vendorId,
    int? categoryId,
    int page = 1,
    int perPage = 20,
  }) async {
    final res = await apiService.get(
      url: ApiPath.getProductsList(
        vendorId: vendorId > 0 ? vendorId : null,
        categoryId: categoryId,
        page: page,
        perPage: perPage,
      ),
      returnDataOnly: false,
    );

    return parsePaginatedResponse(
      res,
      (json) => ProductModel.fromJson(json),
    );
  }

  @override
  Future<ProductModel> getProductDetails(int productId) async {
    final res = await apiService.get(
      url: ApiPath.getProductDetails(productId),
      returnDataOnly: true,
    );

    return ProductModel.fromJson(Map<String, dynamic>.from(res as Map));
  }
}
