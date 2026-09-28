import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/features/games/domain/entities/earn_rewards_params_entity.dart';
import 'package:heraj/features/games/presentation/managers/games_progress_actions_mixin.dart';
import 'package:kingo_games/kingo_games.dart';

class GunShooterGameScreen extends ConsumerStatefulWidget {
  const GunShooterGameScreen({super.key});

  @override
  ConsumerState<GunShooterGameScreen> createState() =>
      _GunShooterGameScreenState();
}

class _GunShooterGameScreenState extends ConsumerState<GunShooterGameScreen>
    with GamesProgressActionsMixin {
  @override
  Widget build(BuildContext context) {
    return GunShooterGameView(
      accentColor: AppColor.primary,
      onBack: () => Get.back(),
      onProgressEnd: (points) => onProgressEnd(
        gameId: GameRewardIds.gunShooter,
        points: points,
      ),
      strings: GunShooterStrings(
        title: 'Gun Shooter'.tr,
        tapToShoot: 'Tap to shoot'.tr,
        hint: 'Aim and shoot the targets before they reach you'.tr,
        gameOver: 'Game Over'.tr,
        yourScore: 'Your score'.tr,
        scoreLabel: 'Score'.tr,
        livesLabel: 'Lives'.tr,
        playAgain: 'Play again'.tr,
        back: 'Back'.tr,
        pointsWonTemplate:
            'You won @count points'.trParams({'count': '{count}'}),
      ),
    );
  }
}
