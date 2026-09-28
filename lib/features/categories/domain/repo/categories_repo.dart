import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/category_model.dart';

abstract class CategoriesRepo {
  Future<Either<Failure, List<CategoryModel>>> getCategoriesByVendorType(
      int vendorTypeId);
}
