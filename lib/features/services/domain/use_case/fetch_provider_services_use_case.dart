import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../entities/provider_service_entity.dart';
import '../repo/services_repo.dart';

class FetchProviderServicesParams {
  const FetchProviderServicesParams({
    this.serviceTypeId,
    this.serviceProviderId,
  });

  final int? serviceTypeId;
  final int? serviceProviderId;

  @override
  bool operator ==(Object other) {
    return other is FetchProviderServicesParams &&
        other.serviceTypeId == serviceTypeId &&
        other.serviceProviderId == serviceProviderId;
  }

  @override
  int get hashCode => Object.hash(serviceTypeId, serviceProviderId);
}

class FetchProviderServicesUseCase extends UseCaseParam<
    List<ProviderServiceEntity>, FetchProviderServicesParams> {
  FetchProviderServicesUseCase({required this.servicesRepo});

  final ServicesRepo servicesRepo;

  @override
  Future<Either<Failure, List<ProviderServiceEntity>>> call(
    FetchProviderServicesParams param,
  ) {
    return servicesRepo.getProviderServices(
      serviceTypeId: param.serviceTypeId,
      serviceProviderId: param.serviceProviderId,
    );
  }
}
