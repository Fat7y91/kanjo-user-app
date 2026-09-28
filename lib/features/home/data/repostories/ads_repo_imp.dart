import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../../core/errors/failure.dart';
import '../../domain/entities/ad_entity.dart';
import '../../domain/repositories/ads_repo.dart';
import '../data_source/ads_data_source.dart';

class AdsRepoImp extends AdsRepo{
  final AdsDataSource adsDataSource;

  AdsRepoImp({required this.adsDataSource});
  @override
  Future<Either<Failure, List<AdEntity>>> getAds() async {
    try {
      final res = await adsDataSource.getBanners();
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }
}