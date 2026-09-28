import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../entities/provider_service_entity.dart';
import '../repo/services_repo.dart';

class FetchServiceProviderUseCase
    extends UseCaseParam<ServiceProviderEntity, int> {
  FetchServiceProviderUseCase({required this.servicesRepo});

  final ServicesRepo servicesRepo;

  @override
  Future<Either<Failure, ServiceProviderEntity>> call(int param) {
    return servicesRepo.getServiceProvider(param);
  }
}
