import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/models/paginated_response.dart';
import '../entities/service_order_entity.dart';
import '../repo/services_repo.dart';

class GetMyServiceOrdersUseCase {
  GetMyServiceOrdersUseCase({required this.servicesRepo});

  final ServicesRepo servicesRepo;

  Future<Either<Failure, PaginatedResponse<ServiceOrderEntity>>> call({
    int page = 1,
    int perPage = 20,
  }) {
    return servicesRepo.getMyServiceOrders(page: page, perPage: perPage);
  }
}
