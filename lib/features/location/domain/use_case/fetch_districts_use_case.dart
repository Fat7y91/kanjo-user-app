import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';
import 'package:heraj/core/use_cases/use_case.dart';
import 'package:heraj/features/location/data/models/district_model.dart';
import 'package:heraj/features/location/domain/repo/location_repo.dart';

class FetchDistrictsParams {
  final String cityCode;

  const FetchDistrictsParams(this.cityCode);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FetchDistrictsParams && other.cityCode == cityCode;
  }

  @override
  int get hashCode => cityCode.hashCode;
}

class FetchDistrictsUseCase
    extends UseCaseParam<DistrictsResponse, FetchDistrictsParams> {
  final LocationRepo _locationRepo;

  FetchDistrictsUseCase(this._locationRepo);

  @override
  Future<Either<Failure, DistrictsResponse>> call(FetchDistrictsParams params) {
    return _locationRepo.getDistricts(params.cityCode);
  }
}
