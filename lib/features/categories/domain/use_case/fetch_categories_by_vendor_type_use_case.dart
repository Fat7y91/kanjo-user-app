import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/category_model.dart';
import '../repo/categories_repo.dart';

class FetchCategoriesByVendorTypeUseCase
    extends UseCaseParam<List<CategoryModel>, int> {
  final CategoriesRepo categoriesRepo;

  FetchCategoriesByVendorTypeUseCase({required this.categoriesRepo});

  @override
  Future<Either<Failure, List<CategoryModel>>> call(int param) {
    return categoriesRepo.getCategoriesByVendorType(param);
  }
}
