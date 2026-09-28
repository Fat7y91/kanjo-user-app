import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';
import 'package:heraj/features/search/data/data_source/search_data_source.dart';
import 'package:heraj/features/search/data/models/app_search_result_model.dart';
import 'package:heraj/features/search/domain/repo/search_repo.dart';

class SearchRepoImp extends SearchRepo {
  SearchRepoImp({required this.dataSource});

  final SearchDataSource dataSource;

  @override
  Future<Either<Failure, AppSearchResultModel>> search(String query) async {
    try {
      final result = await dataSource.search(query);
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }
}
