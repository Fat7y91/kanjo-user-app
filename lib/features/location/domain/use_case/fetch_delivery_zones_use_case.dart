import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';
import 'package:heraj/core/use_cases/use_case.dart';
import 'package:heraj/features/location/domain/entities/delivery_zone_entity.dart';
import 'package:heraj/features/location/domain/repo/location_repo.dart';

class FetchDeliveryZonesUseCase
    extends UseCaseNoParam<List<DeliveryZoneEntity>> {
  FetchDeliveryZonesUseCase(this._locationRepo);

  final LocationRepo _locationRepo;

  @override
  Future<Either<Failure, List<DeliveryZoneEntity>>> call() {
    return _locationRepo.getDeliveryZones();
  }
}
