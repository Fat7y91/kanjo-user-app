import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../entities/service_type_entity.dart';
import '../repo/services_repo.dart';

class FetchServiceTypesUseCase
    extends UseCaseNoParam<List<ServiceTypeEntity>> {
  FetchServiceTypesUseCase({required this.servicesRepo});

  final ServicesRepo servicesRepo;

  @override
  Future<Either<Failure, List<ServiceTypeEntity>>> call() {
    return servicesRepo.getServiceTypes();
  }
}
