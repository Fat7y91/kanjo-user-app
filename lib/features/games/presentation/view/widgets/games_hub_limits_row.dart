import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/games/domain/entities/daily_games_entity.dart';

class GamesHubLimitsRow extends StatelessWidget {
  const GamesHubLimitsRow({super.key, required this.dailyGames});

  final DailyGamesEntity dailyGames;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _LimitChip(
                icon: Icons.sports_esports_rounded,
                label: 'Played today'.tr,
                value: '${dailyGames.played}',
              ),
            ),
            const Gap(8),
            Expanded(
              child: _LimitChip(
                icon: Icons.timelapse_rounded,
                label: 'Remaining today'.tr,
                value: '${dailyGames.remaining}',
                emphasize: dailyGames.remaining <= 0,
              ),
            ),
            const Gap(8),
            Expanded(
              child: _LimitChip(
                icon: Icons.flag_rounded,
                label: 'Daily games'.tr,
                value: '${dailyGames.limit}',
              ),
            ),
          ],
        ),
        if (!dailyGames.canEarnPoints) ...[
          const Gap(10),
          Text(
            'Daily quota reached. You can still play, but you won\'t earn points.'
                .tr,
            textAlign: TextAlign.center,
            style: AppFont.font12w500Grey2,
          ),
        ],
      ],
    );
  }
}

class _LimitChip extends StatelessWidget {
  const _LimitChip({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final color = emphasize ? AppColor.grey2 : AppColor.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.lightBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const Gap(6),
          Text(
            value,
            style: AppFont.font14W700Black.copyWith(color: color),
          ),
          const Gap(2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppFont.font12w500Grey2.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
