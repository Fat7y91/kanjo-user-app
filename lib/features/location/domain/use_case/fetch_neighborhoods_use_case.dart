import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';
import 'package:heraj/core/use_cases/use_case.dart';
import 'package:heraj/features/location/data/models/district_model.dart';
import 'package:heraj/features/location/domain/repo/location_repo.dart';

class FetchNeighborhoodsParams {
  final String cityCode;
  final String districtName;

  const FetchNeighborhoodsParams({
    required this.cityCode,
    required this.districtName,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FetchNeighborhoodsParams &&
        other.cityCode == cityCode &&
        other.districtName == districtName;
  }

  @override
  int get hashCode => Object.hash(cityCode, districtName);
}

class FetchNeighborhoodsUseCase
    extends UseCaseParam<NeighborhoodsResponse, FetchNeighborhoodsParams> {
  final LocationRepo _locationRepo;

  FetchNeighborhoodsUseCase(this._locationRepo);

  @override
  Future<Either<Failure, NeighborhoodsResponse>> call(
      FetchNeighborhoodsParams params) {
    return _locationRepo.getNeighborhoods(
      params.cityCode,
      params.districtName,
    );
  }
}


