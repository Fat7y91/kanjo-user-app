import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../domain/entities/home_sections_content_entity.dart';
import '../../domain/use_case/fetch_home_sections_use_case.dart';

final homeSectionsProvider =
    FutureProvider.autoDispose<HomeSectionsContentEntity>((ref) async {
  final res = await getIt<GetHomeSectionsContentUseCase>().call();
  return res.fold(
    (l) => throw l,
    (r) => r,
  );
});
