import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repo/offers_repo.dart';
import '../data_source/offers_data_source.dart';
import '../models/offer_model.dart';

class OffersRepoImp extends OffersRepo {
  OffersRepoImp({required this.dataSource});

  final OffersDataSource dataSource;

  @override
  Future<Either<Failure, List<OfferModel>>> getOffers({
    double? latitude,
    double? longitude,
    int? zoneId,
  }) async {
    try {
      return Right(
        await dataSource.getOffers(
          latitude: latitude,
          longitude: longitude,
          zoneId: zoneId,
        ),
      );
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }
}
