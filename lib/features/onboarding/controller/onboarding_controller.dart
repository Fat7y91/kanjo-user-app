import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/onboard_list.dart';
import '../data/onboarding_model.dart';

final onboardListProvider =
    Provider.autoDispose<List<OnboardModel>>((ref) => onboardList);

final onboardCurrentIndex = StateProvider.autoDispose<int>((ref) => 1);

final currentOnBoardingData = Provider.autoDispose<OnboardModel>((ref) {
  return ref.read(onboardListProvider)[ref.watch(onboardCurrentIndex)];
});
