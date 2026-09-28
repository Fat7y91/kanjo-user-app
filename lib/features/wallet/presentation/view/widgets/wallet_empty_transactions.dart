import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';

class WalletEmptyTransactions extends StatefulWidget {
  const WalletEmptyTransactions({super.key});

  @override
  State<WalletEmptyTransactions> createState() =>
      _WalletEmptyTransactionsState();
}

class _WalletEmptyTransactionsState extends State<WalletEmptyTransactions>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _bob,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -6 + (_bob.value * 12)),
                child: child,
              );
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColor.primaryDark,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColor.primary,
                size: 32,
              ),
            ),
          ),
          const Gap(16),
          Text(
            'No transactions yet'.tr,
            style: AppFont.font16W700Black,
            textAlign: TextAlign.center,
          ),
          const Gap(6),
          Text(
            'Your wallet activity will appear here'.tr,
            style: AppFont.font12w500Grey2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
