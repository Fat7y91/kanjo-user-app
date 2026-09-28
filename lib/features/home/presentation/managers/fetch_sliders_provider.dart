import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/home/data/models/slider_model.dart';
import 'package:heraj/features/home/domain/use_case/fetch_sliders_params.dart';
import 'package:heraj/features/home/domain/use_case/fetch_sliders_use_case.dart';
import 'package:heraj/features/location/presentation/managers/location_provider.dart';
import '../../../../main.dart';

final fetchSlidersProvider =
    FutureProvider.autoDispose<List<SliderModel>>((ref) async {
  final geo = ref.watch(vendorsGeoParamsProvider);
  final result = await getIt<FetchSlidersUseCase>().call(
    FetchSlidersParams(
      latitude: geo.latitude,
      longitude: geo.longitude,
      zoneId: geo.zoneId,
    ),
  );
  return result.fold((l) => throw l, (r) => r);
});
