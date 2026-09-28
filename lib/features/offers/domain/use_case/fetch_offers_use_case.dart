import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/offer_model.dart';
import '../repo/offers_repo.dart';
import 'fetch_offers_params.dart';

class FetchOffersUseCase
    extends UseCaseParam<List<OfferModel>, FetchOffersParams> {
  FetchOffersUseCase({required this.offersRepo});

  final OffersRepo offersRepo;

  @override
  Future<Either<Failure, List<OfferModel>>> call(FetchOffersParams param) {
    return offersRepo.getOffers(
      latitude: param.latitude,
      longitude: param.longitude,
      zoneId: param.zoneId,
    );
  }
}
