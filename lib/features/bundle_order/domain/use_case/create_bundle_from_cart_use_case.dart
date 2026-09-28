import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/bundle_order_model.dart';
import '../repo/bundle_order_repo.dart';

class CreateBundleFromCartParams {
  final String? notes;

  const CreateBundleFromCartParams({this.notes});
}

class CreateBundleFromCartUseCase
    extends UseCaseParam<BundleOrderModel, CreateBundleFromCartParams> {
  final BundleOrderRepo bundleOrderRepo;

  CreateBundleFromCartUseCase({required this.bundleOrderRepo});

  @override
  Future<Either<Failure, BundleOrderModel>> call(
    CreateBundleFromCartParams param,
  ) {
    return bundleOrderRepo.createBundleFromCart(notes: param.notes);
  }
}
