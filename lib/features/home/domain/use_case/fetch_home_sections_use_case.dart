import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';

import '../../../../core/use_cases/use_case.dart';
import '../entities/home_sections_content_entity.dart';
import '../repositories/home_repo.dart';

class GetHomeSectionsContentUseCase extends UseCaseNoParam<HomeSectionsContentEntity>{
  final HomeRepository repository;

  GetHomeSectionsContentUseCase({required this.repository});

  @override
  Future<Either<Failure, HomeSectionsContentEntity>> call() {
    return repository.getHomeSectionsContent();
  }
}

