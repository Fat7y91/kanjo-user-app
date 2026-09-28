import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/core/errors/failure.dart';
import 'package:heraj/features/cart/presentation/managers/fetch_cart_provider.dart';
import 'package:heraj/features/games/presentation/managers/games_provider.dart';
import 'package:heraj/features/games/presentation/view/widgets/rewards_transactions_bottom_sheet.dart';
import 'package:heraj/features/rewards/data/models/reward_model.dart';
import 'package:heraj/ui/ui.dart';

mixin RewardsActionsMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  void openTransactionsHistory() {
    ref.invalidate(fetchRewardsTransactionsProvider);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RewardsTransactionsBottomSheet(),
    );
  }

  Future<void> onRewardTap({
    required RewardModel reward,
    required int availablePoints,
  }) async {
    if (!reward.isUsable(availablePoints)) {
      final reason = reward.unavailableReason?.trim();
      UIHelper.showGlobalSnackBar(
        text: (reason != null && reason.isNotEmpty)
            ? reason
            : 'Not enough points'.tr,
      );
      return;
    }

    try {
      final cart = await ref.read(fetchCartProvider.future);
      if (cart.isEmpty) {
        UIHelper.showGlobalSnackBar(
          text: 'There are no items to go to the checkout'.tr,
        );
        return;
      }
      Get.toNamed('/checkout', arguments: cart);
    } catch (e) {
      UIHelper.showGlobalSnackBar(
        text: e is Failure ? e.message : e.toString(),
      );
    }
  }
}
