import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';
import 'package:heraj/core/use_cases/use_case.dart';
import 'package:heraj/features/location/data/models/city_model.dart';
import 'package:heraj/features/location/domain/repo/location_repo.dart';

class FetchCitiesUseCase extends UseCaseNoParam<CitiesResponse> {
  final LocationRepo _locationRepo;

  FetchCitiesUseCase(this._locationRepo);

  @override
  Future<Either<Failure, CitiesResponse>> call() {
    return _locationRepo.getCities();
  }
}

