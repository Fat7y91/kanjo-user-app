import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/bundle_order_model.dart';
import '../repo/bundle_order_repo.dart';

class ShowBundleByCodeUseCase
    extends UseCaseParam<BundleOrderModel, String> {
  final BundleOrderRepo bundleOrderRepo;

  ShowBundleByCodeUseCase({required this.bundleOrderRepo});

  @override
  Future<Either<Failure, BundleOrderModel>> call(String code) {
    return bundleOrderRepo.showBundleByCode(code);
  }
}
