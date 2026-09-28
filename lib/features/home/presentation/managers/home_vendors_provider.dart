import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/location/presentation/managers/location_provider.dart';
import 'package:heraj/features/vendor/data/models/vendor_model.dart';
import 'package:heraj/features/vendor/domain/use_case/fetch_vendors_params.dart';
import 'package:heraj/features/vendor/domain/use_case/fetch_vendors_use_case.dart';
import 'package:heraj/main.dart';

final homeVendorsProvider =
    FutureProvider.autoDispose<List<VendorModel>>((ref) async {
  final geo = ref.watch(vendorsGeoParamsProvider);
  final result = await getIt<FetchVendorsUseCase>().call(
    FetchVendorsParams(
      page: 1,
      perPage: 8,
      isFeatured: true,
      latitude: geo.latitude,
      longitude: geo.longitude,
      zoneId: geo.zoneId,
    ),
  );
  return result.fold((l) => throw l, (r) => r.data);
});
