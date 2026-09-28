import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/product_model.dart';
import '../repo/products_repo.dart';
import 'fetch_products_params.dart';

class FetchProductsUseCase
    extends UseCaseParam<PaginatedResponse<ProductModel>, FetchProductsParams> {
  final ProductsRepo productsRepo;

  FetchProductsUseCase({required this.productsRepo});

  @override
  Future<Either<Failure, PaginatedResponse<ProductModel>>> call(
    FetchProductsParams param,
  ) {
    return productsRepo.getProducts(
      vendorId: param.vendorId,
      categoryId: param.categoryId,
      page: param.page,
      perPage: param.perPage,
    );
  }
}
