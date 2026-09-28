import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/categories/data/models/category_model.dart';
import 'package:heraj/features/categories/domain/use_case/fetch_categories_by_vendor_type_use_case.dart';
import 'package:heraj/main.dart';

final fetchCategoriesByVendorTypeProvider = FutureProvider.autoDispose
    .family<List<CategoryModel>, int>((ref, vendorTypeId) async {
  if (vendorTypeId <= 0) return const [];
  final res =
      await getIt<FetchCategoriesByVendorTypeUseCase>().call(vendorTypeId);
  return res.fold((l) => throw l, (r) => r);
});
