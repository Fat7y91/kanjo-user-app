import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/vendor_model.dart';
import '../repo/vendor_repo.dart';
import 'fetch_vendors_params.dart';

class FetchVendorsUseCase
    extends UseCaseParam<PaginatedResponse<VendorModel>, FetchVendorsParams> {
  final VendorRepo vendorRepo;

  FetchVendorsUseCase({required this.vendorRepo});

  @override
  Future<Either<Failure, PaginatedResponse<VendorModel>>> call(
    FetchVendorsParams param,
  ) {
    return vendorRepo.getVendors(
      vendorTypeId: param.vendorTypeId,
      categoryId: param.categoryId,
      search: param.search,
      isFeatured: param.isFeatured,
      offers: param.offers,
      latitude: param.latitude,
      longitude: param.longitude,
      zoneId: param.zoneId,
      page: param.page,
      perPage: param.perPage,
    );
  }
}
