import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/features/home/domain/entities/ad_entity.dart';
import 'package:heraj/features/home/domain/use_case/fetch_ads_use_case.dart';
import '../../../../../main.dart';

final fetchAdsProvider = FutureProvider.autoDispose<List<AdEntity>>((ref) async {
  final loans = await getIt<FetchAdsUseCase>().call();

  return loans.fold((l) {
    throw l;
  }, (r) {
    return r;
  });
});