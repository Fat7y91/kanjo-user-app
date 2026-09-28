import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../data/model/address_model.dart';

abstract class AddressRepo {
  Future<Either<Failure, AddressModel>> addAddress({
    required Map<String, dynamic> map,
  });

  Future<Either<Failure, bool>> updateAddress({
    required String addressId,
    required Map<String, dynamic> map,
  });

  Future<Either<Failure, bool>> deleteAddress({required String addressId});

  Future<Either<Failure, bool>> setDefaultAddress({required String addressId});

  Future<Either<Failure, List<AddressModel>>> getAddresses();
}
