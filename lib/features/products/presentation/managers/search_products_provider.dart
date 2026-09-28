import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/products/data/models/product_model.dart';
import 'package:heraj/features/products/domain/use_case/search_products_use_case.dart';
import 'package:heraj/main.dart';

final searchProductsProvider = FutureProvider.autoDispose
    .family<List<ProductModel>, String>((ref, query) async {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return const [];
  final res = await getIt<SearchProductsUseCase>().call(trimmed);
  return res.fold((l) => throw l, (r) => r.data);
});
