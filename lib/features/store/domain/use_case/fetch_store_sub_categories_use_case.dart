import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';
import '../entities/store_sub_category_entity.dart';
import '../repositories/store_repository.dart';

class FetchStoreSubCategoriesUseCase {
  final StoreRepository repository;

  const FetchStoreSubCategoriesUseCase({required this.repository});

  Future<Either<Failure, List<StoreSubCategoryEntity>>> call() {
    return repository.fetchSubCategories();
  }
}

