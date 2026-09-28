import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/bundle_order_model.dart';
import '../../domain/entities/submit_bundle_params.dart';

abstract class BundleOrderRepo {
  /// GET list my-bundle-orders
  Future<Either<Failure, List<BundleOrderModel>>> listMyBundleOrders();

  /// POST Create bundle (from cart)
  Future<Either<Failure, BundleOrderModel>> createBundleFromCart({
    String? notes,
  });

  /// GET Show bundle by code
  Future<Either<Failure, BundleOrderModel>> showBundleByCode(String code);

  /// POST Add my cart to bundle
  Future<Either<Failure, BundleOrderModel>> addMyCartToBundle(String code);

  /// DEL Remove my bundle item
  Future<Either<Failure, bool>> removeMyBundleItem({
    required String bundleCode,
    required int bundleItemId,
  });

  /// POST Cancel bundle order
  Future<Either<Failure, bool>> cancelBundleOrder(String code);

  /// POST Submit bundle (host only)
  Future<Either<Failure, BundleOrderModel>> submitBundle(
    SubmitBundleParams params,
  );
}
