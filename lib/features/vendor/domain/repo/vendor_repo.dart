import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/models/paginated_response.dart';
import '../../data/models/vendor_model.dart';
import '../../data/models/vendor_type_model.dart';

abstract class VendorRepo {
  Future<Either<Failure, List<VendorTypeModel>>> getVendorTypes();

  Future<Either<Failure, PaginatedResponse<VendorModel>>> getVendors({
    int? vendorTypeId,
    int? categoryId,
    String? search,
    bool isFeatured = false,
    bool offers = false,
    double? latitude,
    double? longitude,
    int? zoneId,
    int page = 1,
    int perPage = 20,
  });
}
