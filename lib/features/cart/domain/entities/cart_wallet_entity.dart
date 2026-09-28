class CartWalletEntity {
  final double balance;

  const CartWalletEntity({required this.balance});

  factory CartWalletEntity.fromJson(Map<String, dynamic> json) {
    return CartWalletEntity(
      balance: json['balance'] is num
          ? (json['balance'] as num).toDouble()
          : double.tryParse(json['balance']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'balance': balance,
      };
}
