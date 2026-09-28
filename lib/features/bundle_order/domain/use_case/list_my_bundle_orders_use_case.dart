import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/bundle_order_model.dart';
import '../repo/bundle_order_repo.dart';

class ListMyBundleOrdersUseCase
    extends UseCaseNoParam<List<BundleOrderModel>> {
  final BundleOrderRepo bundleOrderRepo;

  ListMyBundleOrdersUseCase({required this.bundleOrderRepo});

  @override
  Future<Either<Failure, List<BundleOrderModel>>> call() {
    return bundleOrderRepo.listMyBundleOrders();
  }
}
