import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../repo/bundle_order_repo.dart';

class RemoveBundleItemParams {
  final String bundleCode;
  final int bundleItemId;

  const RemoveBundleItemParams({
    required this.bundleCode,
    required this.bundleItemId,
  });
}

class RemoveMyBundleItemUseCase
    extends UseCaseParam<bool, RemoveBundleItemParams> {
  final BundleOrderRepo bundleOrderRepo;

  RemoveMyBundleItemUseCase({required this.bundleOrderRepo});

  @override
  Future<Either<Failure, bool>> call(RemoveBundleItemParams params) {
    return bundleOrderRepo.removeMyBundleItem(
      bundleCode: params.bundleCode,
      bundleItemId: params.bundleItemId,
    );
  }
}
