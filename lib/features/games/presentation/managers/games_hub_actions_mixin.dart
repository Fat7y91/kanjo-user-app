import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/features/games/presentation/managers/games_provider.dart';
import 'package:heraj/features/games/presentation/view/widgets/rewards_transactions_bottom_sheet.dart';
import 'package:heraj/ui/ui.dart';

mixin GamesHubActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  void openGame({
    required bool enabled,
    required Widget screen,
  }) {
    if (!enabled) {
      UIHelper.showGlobalSnackBar(text: 'Games are currently unavailable'.tr);
      return;
    }
    Get.to(() => screen);
  }

  void openPointsTransactions() {
    ref.invalidate(fetchRewardsTransactionsProvider);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RewardsTransactionsBottomSheet(),
    );
  }
}
