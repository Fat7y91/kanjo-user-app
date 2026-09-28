import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/repo/vendor_repo.dart';
import '../data_source/vendor_data_source.dart';
import '../models/vendor_model.dart';
import '../models/vendor_type_model.dart';

class VendorRepoImp extends VendorRepo {
  final VendorDataSource dataSource;

  VendorRepoImp({required this.dataSource});

  @override
  Future<Either<Failure, List<VendorTypeModel>>> getVendorTypes() async {
    try {
      final types = await dataSource.getVendorTypes();
      return Right(types);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
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
  }) async {
    try {
      final vendors = await dataSource.getVendors(
        vendorTypeId: vendorTypeId,
        categoryId: categoryId,
        search: search,
        isFeatured: isFeatured,
        offers: offers,
        latitude: latitude,
        longitude: longitude,
        zoneId: zoneId,
        page: page,
        perPage: perPage,
      );
      return Right(vendors);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }
}
