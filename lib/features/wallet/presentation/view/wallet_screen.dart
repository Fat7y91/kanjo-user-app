import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/wallet/presentation/managers/fetch_wallet_provider.dart';
import 'package:heraj/features/wallet/presentation/view/widgets/wallet_balance_card.dart';
import 'package:heraj/features/wallet/presentation/view/widgets/wallet_empty_transactions.dart';
import 'package:heraj/features/wallet/presentation/view/widgets/wallet_shimmer.dart';
import 'package:heraj/features/wallet/presentation/view/widgets/wallet_transaction_tile.dart';
import 'package:heraj/helper/riverpod.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(fetchWalletProvider);

    return Scaffold(
      backgroundColor: AppColor.pageBackgroundGrey,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(12),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: AppColor.textDark,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Wallet'.tr,
                      textAlign: TextAlign.center,
                      style: AppFont.font18W700Black,
                    ),
                  ),
                  const SizedBox(width: 40, height: 40),
                ],
              ),
            ),
            Expanded(
              child: walletAsync.customWhen(
                ref: ref,
                refreshable: fetchWalletProvider.future,
                skipLoadingOnRefresh: true,
                loading: () => const WalletShimmer(),
                data: (wallet) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(fetchWalletProvider);
                      await ref.read(fetchWalletProvider.future);
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          sliver: SliverToBoxAdapter(
                            child: WalletBalanceCard(
                              key: ValueKey(wallet.balance),
                              balance: wallet.balance,
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 22, 16, 8),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              'Transactions'.tr,
                              style: AppFont.font16W700Black,
                            ),
                          ),
                        ),
                        if (wallet.transactions.isEmpty)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: WalletEmptyTransactions(),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            sliver: SliverList.separated(
                              itemCount: wallet.transactions.length,
                              separatorBuilder: (_, __) => const Gap(10),
                              itemBuilder: (context, index) {
                                final item = wallet.transactions[index];
                                return TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: 1),
                                  duration: Duration(
                                    milliseconds:
                                        (420 + (index * 70)).clamp(420, 900),
                                  ),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 14 * (1 - value)),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: WalletTransactionTile(
                                    transaction: item,
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
