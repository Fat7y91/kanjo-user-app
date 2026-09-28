import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/repo/bundle_order_repo.dart';
import '../../domain/entities/submit_bundle_params.dart';
import '../data_source/bundle_order_data_source.dart';
import '../models/bundle_order_model.dart';

class BundleOrderRepoImp implements BundleOrderRepo {
  final BundleOrderDataSource dataSource;

  BundleOrderRepoImp({required this.dataSource});

  @override
  Future<Either<Failure, List<BundleOrderModel>>> listMyBundleOrders() async {
    try {
      return Right(await dataSource.listMyBundleOrders());
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, BundleOrderModel>> createBundleFromCart({
    String? notes,
  }) async {
    try {
      return Right(await dataSource.createBundleFromCart(notes: notes));
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, BundleOrderModel>> showBundleByCode(
    String code,
  ) async {
    try {
      return Right(await dataSource.showBundleByCode(code));
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, BundleOrderModel>> addMyCartToBundle(
    String code,
  ) async {
    try {
      return Right(await dataSource.addMyCartToBundle(code));
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, bool>> removeMyBundleItem({
    required String bundleCode,
    required int bundleItemId,
  }) async {
    try {
      return Right(await dataSource.removeMyBundleItem(
        bundleCode: bundleCode,
        bundleItemId: bundleItemId,
      ));
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelBundleOrder(String code) async {
    try {
      return Right(await dataSource.cancelBundleOrder(code));
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, BundleOrderModel>> submitBundle(
    SubmitBundleParams params,
  ) async {
    try {
      return Right(await dataSource.submitBundle(params));
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }
}
