import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/vendor_type_model.dart';
import '../repo/vendor_repo.dart';

class FetchVendorTypesUseCase
    extends UseCaseNoParam<List<VendorTypeModel>> {
  final VendorRepo vendorRepo;

  FetchVendorTypesUseCase({required this.vendorRepo});

  @override
  Future<Either<Failure, List<VendorTypeModel>>> call() {
    return vendorRepo.getVendorTypes();
  }
}
