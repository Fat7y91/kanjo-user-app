import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/wallet/domain/entities/wallet_transaction_entity.dart';
import 'package:heraj/helper/format_date.dart';

class WalletTransactionTile extends StatelessWidget {
  const WalletTransactionTile({super.key, required this.transaction});

  final WalletTransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final credit = transaction.isCredit;
    final amountColor = credit ? AppColor.green : AppColor.danger;
    final title = transaction.description.isNotEmpty
        ? transaction.description
        : transaction.typeLabel.tr;
    final dateText = transaction.createdAt == null
        ? ''
        : FormatDate.call(transaction.createdAt, addJm: true);
    final canOpenOrder =
        transaction.isOrderReference && transaction.referenceId != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canOpenOrder
            ? () => Get.toNamed(
                  '/order-details',
                  arguments: {'id': '${transaction.referenceId}'},
                )
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
                      title,
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
                      '${'Balance after'.tr} ${transaction.displayBalanceAfter} ${'EGP'.tr}',
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
                '${credit ? '+' : '-'}${transaction.displayAmount} ${'EGP'.tr}',
                style: AppFont.font14W700Black.copyWith(color: amountColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
