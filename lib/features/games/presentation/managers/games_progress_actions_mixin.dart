import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/features/games/domain/entities/earn_rewards_params_entity.dart';
import 'package:heraj/features/games/domain/use_case/earn_rewards_use_case.dart';
import 'package:heraj/features/games/presentation/managers/games_provider.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/ui.dart';

mixin GamesProgressActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  Future<void> onProgressEnd({
    required int gameId,
    required int points,
  }) async {
    if (points <= 0) return;

    final remaining = ref.read(fetchGameCenterProvider).maybeWhen(
          data: (center) => center.balance.dailyGames.remaining,
          orElse: () => null,
        );
    if (remaining != null && remaining <= 0) {
      UIHelper.showGlobalSnackBar(
        text:
            'Daily quota reached. You can still play, but you won\'t earn points.'
                .tr,
      );
      return;
    }

    final res = await getIt<EarnRewardsUseCase>().call(
      EarnRewardsParamsEntity(gameId: gameId, points: points),
    );
    res.fold(
      (l) => UIHelper.showGlobalSnackBar(text: l.message),
      (_) {
        if (mounted) {
          ref.invalidate(fetchGameCenterProvider);
        }
      },
    );
  }
}
