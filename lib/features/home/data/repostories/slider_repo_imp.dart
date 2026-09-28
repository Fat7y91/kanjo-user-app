import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repositories/slider_repo.dart';
import '../data_source/slider_data_source.dart';
import '../models/slider_model.dart';

class SliderRepoImp extends SliderRepo {
  final SliderDataSource sliderDataSource;

  SliderRepoImp({required this.sliderDataSource});

  @override
  Future<Either<Failure, List<SliderModel>>> getSliders({
    double? latitude,
    double? longitude,
    int? zoneId,
  }) async {
    try {
      final res = await sliderDataSource.getSliders(
        latitude: latitude,
        longitude: longitude,
        zoneId: zoneId,
      );
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }
}
