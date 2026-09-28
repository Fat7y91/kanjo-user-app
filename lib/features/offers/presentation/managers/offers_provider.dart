import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/location/presentation/managers/location_provider.dart';
import 'package:heraj/features/offers/data/models/offer_model.dart';
import 'package:heraj/features/offers/domain/use_case/fetch_offers_params.dart';
import 'package:heraj/features/offers/domain/use_case/fetch_offers_use_case.dart';
import 'package:heraj/main.dart';

final fetchOffersProvider =
    FutureProvider.autoDispose<List<OfferModel>>((ref) async {
  final geo = ref.watch(vendorsGeoParamsProvider);
  final res = await getIt<FetchOffersUseCase>().call(
    FetchOffersParams(
      latitude: geo.latitude,
      longitude: geo.longitude,
      zoneId: geo.zoneId,
    ),
  );
  return res.fold((l) => throw l, (r) => r);
});
