import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/models/paginated_response.dart';
import '../../data/models/product_model.dart';

abstract class ProductsRepo {
  Future<Either<Failure, PaginatedResponse<ProductModel>>> searchProducts(
    String query, {
    int? vendorId,
    int page = 1,
    int perPage = 20,
  });

  Future<Either<Failure, PaginatedResponse<ProductModel>>> getProducts({
    required int vendorId,
    int? categoryId,
    int page = 1,
    int perPage = 20,
  });

  Future<Either<Failure, ProductModel>> getProductDetails(int productId);
}
