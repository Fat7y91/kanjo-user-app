import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/product_model.dart';
import '../repo/products_repo.dart';

class GetProductDetailsUseCase extends UseCaseParam<ProductModel, int> {
  final ProductsRepo productsRepo;

  GetProductDetailsUseCase({required this.productsRepo});

  @override
  Future<Either<Failure, ProductModel>> call(int param) {
    return productsRepo.getProductDetails(param);
  }
}
