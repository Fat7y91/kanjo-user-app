import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/product_model.dart';
import '../repo/products_repo.dart';

class SearchProductsUseCase
    extends UseCaseParam<PaginatedResponse<ProductModel>, String> {
  final ProductsRepo productsRepo;

  SearchProductsUseCase({required this.productsRepo});

  @override
  Future<Either<Failure, PaginatedResponse<ProductModel>>> call(String param) {
    return productsRepo.searchProducts(param);
  }
}
