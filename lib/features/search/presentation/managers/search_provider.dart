import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/search/data/models/app_search_result_model.dart';
import 'package:heraj/features/search/domain/use_case/search_app_use_case.dart';
import 'package:heraj/main.dart';

final appSearchProvider = FutureProvider.autoDispose
    .family<AppSearchResultModel, String>((ref, query) async {
  final trimmed = query.trim();
  if (trimmed.isEmpty) {
    return const AppSearchResultModel(query: '');
  }
  final res = await getIt<SearchAppUseCase>().call(trimmed);
  return res.fold((l) => throw l, (r) => r);
});
