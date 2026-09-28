import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../repo/bundle_order_repo.dart';

class CancelBundleOrderUseCase extends UseCaseParam<bool, String> {
  CancelBundleOrderUseCase({required this.bundleOrderRepo});

  final BundleOrderRepo bundleOrderRepo;

  @override
  Future<Either<Failure, bool>> call(String code) {
    return bundleOrderRepo.cancelBundleOrder(code);
  }
}
