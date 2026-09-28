class WalletTransactionEntity {
  final int id;
  final String type;
  final String displayAmount;
  final double amount;
  final String displayBalanceAfter;
  final double balanceAfter;
  final String description;
  final String referenceType;
  final int? referenceId;
  final DateTime? createdAt;

  const WalletTransactionEntity({
    required this.id,
    required this.type,
    required this.displayAmount,
    required this.amount,
    required this.displayBalanceAfter,
    required this.balanceAfter,
    required this.description,
    this.referenceType = '',
    this.referenceId,
    this.createdAt,
  });

  bool get isCredit {
    final t = type.toLowerCase();
    if (t.startsWith('debit') || t.contains('debit')) return false;
    if (t.startsWith('credit') ||
        t.contains('credit') ||
        t.contains('refund')) {
      return true;
    }
    return amount >= 0;
  }

  bool get isOrderReference {
    final ref = referenceType.toLowerCase();
    return ref.contains('order') || referenceId != null;
  }

  String get typeLabel {
    final t = type.toLowerCase();
    if (t.contains('refund')) return 'Refund';
    if (t.contains('checkout')) return 'Checkout';
    if (t.contains('deposit')) return 'Deposit';
    if (t.contains('withdraw')) return 'Withdraw';
    return isCredit ? 'Credit' : 'Debit';
  }

  factory WalletTransactionEntity.fromJson(Map<String, dynamic> json) {
    final amountRaw = json['amount'];
    final balanceAfterRaw = json['balance_after'];
    final referenceIdRaw = json['reference_id'];
    return WalletTransactionEntity(
      id: _parseInt(json['id']) ?? 0,
      type: json['type']?.toString() ?? '',
      displayAmount: amountRaw?.toString() ?? '0.00',
      amount: _parseAmount(amountRaw),
      displayBalanceAfter: balanceAfterRaw?.toString() ?? '0.00',
      balanceAfter: _parseAmount(balanceAfterRaw),
      description: json['description']?.toString() ?? '',
      referenceType: json['reference_type']?.toString() ?? '',
      referenceId: _parseInt(referenceIdRaw),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'amount': displayAmount,
        'balance_after': displayBalanceAfter,
        'description': description,
        'reference_type': referenceType,
        'reference_id': referenceId,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
