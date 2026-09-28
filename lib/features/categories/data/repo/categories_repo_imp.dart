import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/repo/categories_repo.dart';
import '../data_source/categories_data_source.dart';
import '../models/category_model.dart';

class CategoriesRepoImp implements CategoriesRepo {
  final CategoriesDataSource dataSource;

  CategoriesRepoImp({required this.dataSource});

  @override
  Future<Either<Failure, List<CategoryModel>>> getCategoriesByVendorType(
      int vendorTypeId) async {
    try {
      final categories =
          await dataSource.getCategoriesByVendorType(vendorTypeId);
      return Right(categories);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }
}
