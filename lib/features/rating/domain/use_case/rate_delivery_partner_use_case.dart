import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/rating_params_entity.dart';
import '../repo/rating_repo.dart';

class RateDeliveryPartnerUseCase
    extends UseCaseParam<bool, RatingParamsEntity> {
  RateDeliveryPartnerUseCase({required this.ratingRepo});

  final RatingRepo ratingRepo;

  @override
  Future<Either<Failure, bool>> call(RatingParamsEntity param) {
    return ratingRepo.rateDeliveryPartner(param);
  }
}
