import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/products/data/models/product_model.dart';
import 'package:heraj/features/products/domain/use_case/get_product_details_use_case.dart';
import 'package:heraj/main.dart';

final productDetailsProvider =
    FutureProvider.autoDispose.family<ProductModel, int>((ref, productId) async {
  final res = await getIt<GetProductDetailsUseCase>().call(productId);
  return res.fold((l) => throw l, (r) => r);
});
