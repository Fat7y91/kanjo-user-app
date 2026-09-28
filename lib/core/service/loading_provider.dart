import 'package:flutter_riverpod/flutter_riverpod.dart';

final isLoadingProvider =
    StateProvider.family.autoDispose<bool, dynamic>((ref, _) {
  return false;
});

final downloadingProcessProvider =
    StateProvider.family.autoDispose<int?, dynamic>((ref, _) {
  return null;
});
