import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../entities/provider_service_entity.dart';
import '../repo/services_repo.dart';

class FetchServiceProvidersParams {
  const FetchServiceProvidersParams({
    this.serviceTypeId,
    this.search,
  });

  final int? serviceTypeId;
  final String? search;

  @override
  bool operator ==(Object other) {
    return other is FetchServiceProvidersParams &&
        other.serviceTypeId == serviceTypeId &&
        other.search == search;
  }

  @override
  int get hashCode => Object.hash(serviceTypeId, search);
}

class FetchServiceProvidersUseCase extends UseCaseParam<
    List<ServiceProviderEntity>, FetchServiceProvidersParams> {
  FetchServiceProvidersUseCase({required this.servicesRepo});

  final ServicesRepo servicesRepo;

  @override
  Future<Either<Failure, List<ServiceProviderEntity>>> call(
    FetchServiceProvidersParams param,
  ) {
    return servicesRepo.getServiceProviders(
      serviceTypeId: param.serviceTypeId,
      search: param.search,
    );
  }
}
