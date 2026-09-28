import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';
import '../../domain/entities/store_category_entity.dart';
import '../../domain/entities/store_sub_category_entity.dart';
import '../../domain/repositories/store_repository.dart';
import '../data_source/store_data_source.dart';

class StoreRepoImpl implements StoreRepository {
  final StoreDataSource dataSource;

  const StoreRepoImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<StoreCategoryEntity>>> fetchCategories() async {
    try {
      final categories = await dataSource.fetchCategories();
      return Right(categories);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, List<StoreSubCategoryEntity>>> fetchSubCategories() async {
    try {
      final subCategories = await dataSource.fetchSubCategories();
      return Right(subCategories);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }
}

