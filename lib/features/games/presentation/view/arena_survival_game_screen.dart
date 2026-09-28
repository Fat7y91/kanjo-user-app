import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/local_data_manager_key.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/features/games/domain/entities/earn_rewards_params_entity.dart';
import 'package:heraj/features/games/presentation/managers/games_progress_actions_mixin.dart';
import 'package:kingo_games/kingo_games.dart';

class ArenaSurvivalGameScreen extends ConsumerStatefulWidget {
  const ArenaSurvivalGameScreen({super.key});

  @override
  ConsumerState<ArenaSurvivalGameScreen> createState() =>
      _ArenaSurvivalGameScreenState();
}

class _ArenaSurvivalGameScreenState extends ConsumerState<ArenaSurvivalGameScreen>
    with GamesProgressActionsMixin {
  @override
  Widget build(BuildContext context) {
    return ArenaSurvivalGameView(
      accentColor: AppColor.primary,
      onBack: () => Get.back(),
      onProgressEnd: (points) => onProgressEnd(
        gameId: GameRewardIds.arenaSurvival,
        points: points,
      ),
      storage: CallbackArenaGameStorage(
        readJson: () {
          final raw = dataManager.getValue(LocalDataManagerKeys.arenaSurvival);
          if (raw is Map<String, dynamic>) return raw;
          if (raw is Map) return Map<String, dynamic>.from(raw);
          return null;
        },
        writeJson: (json) =>
            dataManager.setValue(LocalDataManagerKeys.arenaSurvival, json),
      ),
      strings: ArenaSurvivalStrings(
        title: 'Arena Survival'.tr,
        subtitle: 'Survive 5 minutes and defeat the guardian'.tr,
        play: 'Play'.tr,
        continueRun: 'Continue chapter'.tr,
        upgrades: 'Upgrades'.tr,
        settings: 'Settings'.tr,
        coins: 'Coins'.tr,
        chapter: 'Chapter'.tr,
        pause: 'Pause'.tr,
        resume: 'Resume'.tr,
        restart: 'Restart'.tr,
        mainMenu: 'Main Menu'.tr,
        gamePaused: 'Game Paused'.tr,
        levelUp: 'Level Up!'.tr,
        chooseUpgrade: 'Choose one upgrade'.tr,
        gameOver: 'Game Over'.tr,
        victory: 'Victory!'.tr,
        bossDefeated: 'Boss Defeated'.tr,
        survivalTime: 'Survival Time'.tr,
        level: 'Level'.tr,
        kills: 'Enemies Defeated'.tr,
        coinsEarned: 'Coins Earned'.tr,
        playAgain: 'Play again'.tr,
        back: 'Back'.tr,
        hp: 'HP'.tr,
        damage: 'Damage'.tr,
        moveSpeed: 'Movement Speed'.tr,
        pickupRadius: 'XP Pickup Radius'.tr,
        upgrade: 'Upgrade'.tr,
        maxLevel: 'Max'.tr,
        cost: 'Cost'.tr,
        music: 'Music Volume'.tr,
        sfx: 'SFX Volume'.tr,
        bestTime: 'Best Time'.tr,
        highestLevel: 'Highest Level'.tr,
        totalKills: 'Total Kills'.tr,
        countdownGo: 'GO!'.tr,
        pointsWonTemplate:
            'You won @count points'.trParams({'count': '{count}'}),
      ),
    );
  }
}
