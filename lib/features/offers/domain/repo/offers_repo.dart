import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../data/models/offer_model.dart';

abstract class OffersRepo {
  Future<Either<Failure, List<OfferModel>>> getOffers({
    double? latitude,
    double? longitude,
    int? zoneId,
  });
}
