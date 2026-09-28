import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/rewards/data/models/reward_model.dart';
import 'package:heraj/features/rewards/presentation/managers/rewards_provider.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';

class CheckoutRewardsBottomSheet extends ConsumerWidget {
  const CheckoutRewardsBottomSheet({
    super.key,
    required this.orderAmount,
    required this.selectedRewardId,
    required this.onSelected,
    required this.onCleared,
  });

  final double orderAmount;
  final int? selectedRewardId;
  final ValueChanged<RewardModel> onSelected;
  final VoidCallback onCleared;

  String _discountLabel(RewardModel reward) {
    final value = reward.discountValue % 1 == 0
        ? reward.discountValue.toStringAsFixed(0)
        : reward.discountValue.toStringAsFixed(2);
    if (reward.isPercentDiscount) {
      return '$value%';
    }
    return '$value ${'EGP'.tr}';
  }

  String _money(double v) {
    final text = v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
    return '$text ${'EGP'.tr}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final centerAsync = ref.watch(fetchRewardsCenterProvider);
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.paddingOf(context).bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColor.grey1,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const Gap(16),
            Text(
              'Available rewards'.tr,
              style: AppFont.font18W700Black,
            ),
            const Gap(12),
            Flexible(
              child: centerAsync.customWhen(
                ref: ref,
                refreshable: fetchRewardsCenterProvider.future,
                loading: () => const PageLoadingWidget(),
                data: (center) {
                  final rewards = center.rewards
                      .where(
                        (reward) => reward.isValidForCheckout(
                          availablePoints: center.balance.pointsBalance,
                          orderAmount: orderAmount,
                        ),
                      )
                      .toList();
                  if (rewards.isEmpty) {
                    return Center(
                      child: Text(
                        'No valid rewards'.tr,
                        style: AppFont.font14W500Black,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: rewards.length,
                    separatorBuilder: (_, __) => const Gap(8),
                    itemBuilder: (context, index) {
                      final reward = rewards[index];
                      final selected = reward.id == selectedRewardId;
                      final name = reward.name.localized(languageCode);
                      final description =
                          reward.description.localized(languageCode);
                      final discount = reward.discountAmountFor(orderAmount);
                      return Material(
                        color: selected
                            ? const Color(0xFFF7EFFF)
                            : AppColor.white,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => onSelected(reward),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? AppColor.primary
                                    : AppColor.checkoutBorder,
                                width: selected ? 1.4 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  selected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: selected
                                      ? AppColor.primary
                                      : AppColor.radioBorderGrey,
                                  size: 20,
                                ),
                                const Gap(10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: AppFont.font14W700Black,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Gap(4),
                                      Text(
                                        '@count Points'.trParams({
                                          'count': '${reward.requiredPoints}',
                                        }),
                                        style: AppFont.font12w500Grey2,
                                      ),
                                      if (description.isNotEmpty) ...[
                                        const Gap(2),
                                        Text(
                                          description,
                                          style: AppFont.font12w500Grey2
                                              .copyWith(
                                            color: AppColor.textBodyTertiary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      if (reward.minimumOrderAmount > 0) ...[
                                        const Gap(2),
                                        Text(
                                          'Min. order @amount'.trParams({
                                            'amount':
                                                _money(reward.minimumOrderAmount),
                                          }),
                                          style: AppFont.font12w500Grey2,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const Gap(8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '- ${_money(discount)}',
                                      style: AppFont.font14W700Black.copyWith(
                                        color: AppColor.guestOrange,
                                      ),
                                    ),
                                    const Gap(2),
                                    Text(
                                      _discountLabel(reward),
                                      style: AppFont.font12w500Grey2.copyWith(
                                        color: AppColor.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (selectedRewardId != null) ...[
              const Gap(12),
              InkWell(
                onTap: onCleared,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Remove reward'.tr,
                    style: AppFont.font14W700Black.copyWith(
                      color: AppColor.danger,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
