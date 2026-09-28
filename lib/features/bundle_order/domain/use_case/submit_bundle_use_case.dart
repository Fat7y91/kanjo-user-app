import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/bundle_order_model.dart';
import '../entities/submit_bundle_params.dart';
import '../repo/bundle_order_repo.dart';

class SubmitBundleUseCase
    extends UseCaseParam<BundleOrderModel, SubmitBundleParams> {
  SubmitBundleUseCase({required this.bundleOrderRepo});

  final BundleOrderRepo bundleOrderRepo;

  @override
  Future<Either<Failure, BundleOrderModel>> call(SubmitBundleParams params) {
    return bundleOrderRepo.submitBundle(params);
  }
}
