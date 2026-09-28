import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/games/domain/entities/reward_transaction_entity.dart';
import 'package:heraj/features/games/presentation/managers/games_provider.dart';
import 'package:heraj/helper/format_date.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';

class RewardsTransactionsBottomSheet extends ConsumerWidget {
  const RewardsTransactionsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(fetchRewardsTransactionsProvider);
    final maxHeight = MediaQuery.of(context).size.height * 0.78;

    return SizedBox(
      height: maxHeight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.pageBackgroundGrey,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const Gap(10),
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColor.grey1,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const Gap(16),
              Text(
                'Points history'.tr,
                style: AppFont.font18W700Black,
              ),
              const Gap(16),
              Expanded(
                child: async.customWhen(
                  ref: ref,
                  refreshable: fetchRewardsTransactionsProvider.future,
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: PageLoadingWidget(),
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                        child: Text(
                          'No transactions yet'.tr,
                          textAlign: TextAlign.center,
                          style: AppFont.font12w500Grey2,
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Gap(10),
                      itemBuilder: (context, index) {
                        return _TransactionTile(transaction: items[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final RewardTransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final credit = transaction.isCredit;
    final amountColor = credit ? AppColor.primary : AppColor.danger;
    final dateText = transaction.createdAt == null
        ? ''
        : FormatDate.call(transaction.createdAt, addJm: true);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: amountColor.withAlpha(24),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(
              credit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: amountColor,
              size: 22,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.titleKey.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.font14W700Black,
                ),
                const Gap(4),
                Text(
                  [
                    transaction.typeLabel.tr,
                    if (dateText.isNotEmpty) dateText,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.font12w500Grey2,
                ),
                const Gap(4),
                Text(
                  '${'Balance after'.tr} ${transaction.balanceAfter}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.font12w500Grey2.copyWith(
                    color: AppColor.textBodySecondary,
                  ),
                ),
              ],
            ),
          ),
          const Gap(10),
          Text(
            '${credit ? '+' : '-'}${transaction.points}',
            style: AppFont.font14W700Black.copyWith(color: amountColor),
          ),
        ],
      ),
    );
  }
}
