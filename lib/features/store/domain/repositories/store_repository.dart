import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';
import '../entities/store_category_entity.dart';
import '../entities/store_sub_category_entity.dart';

abstract class StoreRepository {
  Future<Either<Failure, List<StoreCategoryEntity>>> fetchCategories();
  Future<Either<Failure, List<StoreSubCategoryEntity>>> fetchSubCategories();
}

