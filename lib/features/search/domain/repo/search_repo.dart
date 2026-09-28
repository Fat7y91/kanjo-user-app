import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';
import 'package:heraj/features/search/data/models/app_search_result_model.dart';

abstract class SearchRepo {
  Future<Either<Failure, AppSearchResultModel>> search(String query);
}
