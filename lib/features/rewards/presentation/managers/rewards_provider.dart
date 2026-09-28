import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/games/domain/use_case/fetch_rewards_balance_use_case.dart';
import 'package:heraj/features/rewards/data/models/rewards_center_model.dart';
import 'package:heraj/features/rewards/domain/use_case/fetch_rewards_use_case.dart';
import 'package:heraj/main.dart';

final fetchRewardsCenterProvider =
    FutureProvider.autoDispose<RewardsCenterModel>((ref) async {
  final rewardsFuture = getIt<FetchRewardsUseCase>().call();
  final balanceFuture = getIt<FetchRewardsBalanceUseCase>().call();
  final rewardsRes = await rewardsFuture;
  final balanceRes = await balanceFuture;
  return RewardsCenterModel(
    rewards: rewardsRes.fold((l) => throw l, (r) => r),
    balance: balanceRes.fold((l) => throw l, (r) => r),
  );
});
