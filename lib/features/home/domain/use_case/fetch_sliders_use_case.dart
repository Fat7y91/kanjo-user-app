import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';
import 'package:heraj/core/use_cases/use_case.dart';
import '../../data/models/slider_model.dart';
import '../repositories/slider_repo.dart';
import 'fetch_sliders_params.dart';

class FetchSlidersUseCase
    extends UseCaseParam<List<SliderModel>, FetchSlidersParams> {
  final SliderRepo sliderRepo;

  FetchSlidersUseCase({required this.sliderRepo});

  @override
  Future<Either<Failure, List<SliderModel>>> call(FetchSlidersParams param) {
    return sliderRepo.getSliders(
      latitude: param.latitude,
      longitude: param.longitude,
      zoneId: param.zoneId,
    );
  }
}
