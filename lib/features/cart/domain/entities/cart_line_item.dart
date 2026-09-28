class CartLineItem {
  const CartLineItem({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    required this.unitPriceEgp,
    required this.quantity,
    required this.imageAsset,
  });

  final String id;
  /// Translation key passed to `.tr`.
  final String titleKey;
  final String subtitleKey;
  final int unitPriceEgp;
  final int quantity;
  final String imageAsset;

  CartLineItem copyWith({int? quantity}) {
    return CartLineItem(
      id: id,
      titleKey: titleKey,
      subtitleKey: subtitleKey,
      unitPriceEgp: unitPriceEgp,
      quantity: quantity ?? this.quantity,
      imageAsset: imageAsset,
    );
  }
}
