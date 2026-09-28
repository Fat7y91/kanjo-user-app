import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/games/data/models/game_center_model.dart';
import 'package:heraj/features/games/domain/entities/reward_transaction_entity.dart';
import 'package:heraj/features/games/domain/use_case/fetch_game_config_use_case.dart';
import 'package:heraj/features/games/domain/use_case/fetch_rewards_balance_use_case.dart';
import 'package:heraj/features/games/domain/use_case/fetch_rewards_transactions_use_case.dart';
import 'package:heraj/main.dart';

final fetchGameCenterProvider =
    FutureProvider.autoDispose<GameCenterModel>((ref) async {
  final configFuture = getIt<FetchGameConfigUseCase>().call();
  final balanceFuture = getIt<FetchRewardsBalanceUseCase>().call();
  final configRes = await configFuture;
  final balanceRes = await balanceFuture;
  return GameCenterModel(
    config: configRes.fold((l) => throw l, (r) => r),
    balance: balanceRes.fold((l) => throw l, (r) => r),
  );
});

final fetchRewardsTransactionsProvider =
    FutureProvider.autoDispose<List<RewardTransactionEntity>>((ref) async {
  final res = await getIt<FetchRewardsTransactionsUseCase>().call();
  return res.fold((l) => throw l, (r) => r);
});
