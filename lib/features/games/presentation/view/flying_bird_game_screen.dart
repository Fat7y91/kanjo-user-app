import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/features/games/domain/entities/earn_rewards_params_entity.dart';
import 'package:heraj/features/games/presentation/managers/games_progress_actions_mixin.dart';
import 'package:kingo_games/kingo_games.dart';

class FlyingBirdGameScreen extends ConsumerStatefulWidget {
  const FlyingBirdGameScreen({super.key});

  @override
  ConsumerState<FlyingBirdGameScreen> createState() =>
      _FlyingBirdGameScreenState();
}

class _FlyingBirdGameScreenState extends ConsumerState<FlyingBirdGameScreen>
    with GamesProgressActionsMixin {
  @override
  Widget build(BuildContext context) {
    return FlyingBirdGameView(
      accentColor: AppColor.primary,
      onBack: () => Get.back(),
      onProgressEnd: (points) => onProgressEnd(
        gameId: GameRewardIds.flyingBird,
        points: points,
      ),
      strings: FlyingBirdStrings(
        title: 'Flying Bird'.tr,
        tapToFly: 'Tap to fly'.tr,
        passPipesHint: 'Pass the pipes to win points'.tr,
        gameOver: 'Game Over'.tr,
        yourScore: 'Your score'.tr,
        scoreLabel: 'Score'.tr,
        playAgain: 'Play again'.tr,
        back: 'Back'.tr,
        pointsWonTemplate:
            'You won @count points'.trParams({'count': '{count}'}),
      ),
    );
  }
}
