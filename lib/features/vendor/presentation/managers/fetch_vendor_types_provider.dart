import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/vendor/data/models/vendor_type_model.dart';
import 'package:heraj/features/vendor/domain/use_case/fetch_vendor_types_use_case.dart';
import 'package:heraj/main.dart';

final fetchVendorTypesProvider =
    FutureProvider.autoDispose<List<VendorTypeModel>>((ref) async {
  final res = await getIt<FetchVendorTypesUseCase>().call();
  return res.fold((l) => throw l, (r) => r);
});
