import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/repo/products_repo.dart';
import '../data_source/products_data_source.dart';
import '../models/product_model.dart';

class ProductsRepoImp implements ProductsRepo {
  final ProductsDataSource dataSource;

  ProductsRepoImp({required this.dataSource});

  @override
  Future<Either<Failure, PaginatedResponse<ProductModel>>> searchProducts(
    String query, {
    int? vendorId,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final products = await dataSource.searchProducts(
        query,
        vendorId: vendorId,
        page: page,
        perPage: perPage,
      );
      return Right(products);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, PaginatedResponse<ProductModel>>> getProducts({
    required int vendorId,
    int? categoryId,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final products = await dataSource.getProducts(
        vendorId: vendorId,
        categoryId: categoryId,
        page: page,
        perPage: perPage,
      );
      return Right(products);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, ProductModel>> getProductDetails(
      int productId) async {
    try {
      final product = await dataSource.getProductDetails(productId);
      return Right(product);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }
}
