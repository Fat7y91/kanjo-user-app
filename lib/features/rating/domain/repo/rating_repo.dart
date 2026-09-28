import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/rating_params_entity.dart';

abstract class RatingRepo {
  Future<Either<Failure, bool>> rateVendor(RatingParamsEntity params);

  Future<Either<Failure, bool>> rateDeliveryPartner(RatingParamsEntity params);
}
