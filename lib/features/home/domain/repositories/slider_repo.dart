import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';
import '../../data/models/slider_model.dart';

abstract class SliderRepo {
  Future<Either<Failure, List<SliderModel>>> getSliders({
    double? latitude,
    double? longitude,
    int? zoneId,
  });
}
