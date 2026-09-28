import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';
import '../entities/store_category_entity.dart';
import '../repositories/store_repository.dart';

class FetchStoreCategoriesUseCase {
  final StoreRepository repository;

  const FetchStoreCategoriesUseCase({required this.repository});

  Future<Either<Failure, List<StoreCategoryEntity>>> call() {
    return repository.fetchCategories();
  }
}

