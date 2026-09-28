import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/bundle_order/data/models/bundle_order_model.dart';
import 'package:heraj/features/bundle_order/domain/use_case/list_my_bundle_orders_use_case.dart';
import 'package:heraj/features/bundle_order/domain/use_case/show_bundle_by_code_use_case.dart';
import 'package:heraj/main.dart';

final myBundleOrdersProvider =
    FutureProvider.autoDispose<List<BundleOrderModel>>((ref) async {
  final res = await getIt<ListMyBundleOrdersUseCase>().call();
  return res.fold((l) => throw l, (r) => r);
});

final bundleOrderByCodeProvider = FutureProvider.autoDispose
    .family<BundleOrderModel, String>((ref, code) async {
  final res = await getIt<ShowBundleByCodeUseCase>().call(code);
  return res.fold((l) => throw l, (r) => r);
});
