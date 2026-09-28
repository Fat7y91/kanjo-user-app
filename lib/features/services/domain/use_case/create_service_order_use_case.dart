import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../entities/create_service_order_params.dart';
import '../repo/services_repo.dart';

class CreateServiceOrderUseCase
    extends UseCaseParam<bool, CreateServiceOrderParams> {
  CreateServiceOrderUseCase({required this.servicesRepo});

  final ServicesRepo servicesRepo;

  @override
  Future<Either<Failure, bool>> call(CreateServiceOrderParams param) {
    return servicesRepo.createServiceOrder(param);
  }
}
