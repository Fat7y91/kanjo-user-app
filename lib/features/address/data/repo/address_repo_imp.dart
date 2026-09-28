import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/repo/address_repo.dart';
import '../data_source/address_data_source.dart';
import '../model/address_model.dart';

class AddressRepoImp extends AddressRepo {
  final AddressDataSource addressDataSource;

  AddressRepoImp({required this.addressDataSource});

  @override
  Future<Either<Failure, AddressModel>> addAddress({
    required Map<String, dynamic> map,
  }) async {
    try {
      final res = await addressDataSource.addAddress(map: map);
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, bool>> updateAddress({
    required String addressId,
    required Map<String, dynamic> map,
  }) async {
    try {
      final res = await addressDataSource.updateAddress(
        addressId: addressId,
        map: map,
      );
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAddress({
    required String addressId,
  }) async {
    try {
      final res =
          await addressDataSource.deleteAddress(addressId: addressId);
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, bool>> setDefaultAddress({
    required String addressId,
  }) async {
    try {
      final res =
          await addressDataSource.setDefaultAddress(addressId: addressId);
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, List<AddressModel>>> getAddresses() async {
    try {
      final res = await addressDataSource.getAddresses();
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }
}
