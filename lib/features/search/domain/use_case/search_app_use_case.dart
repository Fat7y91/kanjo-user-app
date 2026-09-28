import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';
import 'package:heraj/core/use_cases/use_case.dart';
import 'package:heraj/features/search/data/models/app_search_result_model.dart';
import 'package:heraj/features/search/domain/repo/search_repo.dart';

class SearchAppUseCase
    extends UseCaseParam<AppSearchResultModel, String> {
  SearchAppUseCase({required this.searchRepo});

  final SearchRepo searchRepo;

  @override
  Future<Either<Failure, AppSearchResultModel>> call(String param) {
    return searchRepo.search(param);
  }
}
