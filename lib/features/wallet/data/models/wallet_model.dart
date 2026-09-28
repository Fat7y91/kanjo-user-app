import '../../domain/entities/wallet_transaction_entity.dart';

class WalletModel {
  final String displayBalance;
  final double balance;
  final List<WalletTransactionEntity> transactions;

  const WalletModel({
    required this.displayBalance,
    required this.balance,
    required this.transactions,
  });

  const WalletModel.empty()
      : displayBalance = '0.00',
        balance = 0,
        transactions = const [];

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final rawBalance = json['balance'];
    final transactionsRaw = json['transactions'];
    return WalletModel(
      displayBalance: rawBalance?.toString() ?? '0.00',
      balance: _parseAmount(rawBalance),
      transactions: transactionsRaw is List
          ? transactionsRaw
              .whereType<Map>()
              .map(
                (item) => WalletTransactionEntity.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'balance': displayBalance,
        'transactions': transactions.map((e) => e.toJson()).toList(),
      };

  static double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
