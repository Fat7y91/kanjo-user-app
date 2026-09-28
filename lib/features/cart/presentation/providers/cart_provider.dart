import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/cart_line_item.dart';

final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartLineItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartLineItem>> {
  CartNotifier() : super(_seed);

  static const String _imgFood = 'assets/dummy_images/home_category_food.png';
  static const String _imgRice = 'assets/dummy_images/home_category_grocery.png';

  static final List<CartLineItem> _seed = [
    CartLineItem(
      id: '1',
      titleKey: 'Cart item roast chicken',
      subtitleKey: 'Cart item rice vermicelli subtitle',
      unitPriceEgp: 50,
      quantity: 1,
      imageAsset: _imgFood,
    ),
    CartLineItem(
      id: '2',
      titleKey: 'Cart item rice vermicelli',
      subtitleKey: 'Cart item rice vermicelli subtitle',
      unitPriceEgp: 50,
      quantity: 1,
      imageAsset: _imgRice,
    ),
    CartLineItem(
      id: '3',
      titleKey: 'Cart item roast chicken',
      subtitleKey: 'Cart item rice vermicelli subtitle',
      unitPriceEgp: 50,
      quantity: 1,
      imageAsset: _imgFood,
    ),
    CartLineItem(
      id: '4',
      titleKey: 'Cart item rice vermicelli',
      subtitleKey: 'Cart item rice vermicelli subtitle',
      unitPriceEgp: 50,
      quantity: 1,
      imageAsset: _imgRice,
    ),
    CartLineItem(
      id: '5',
      titleKey: 'Cart item roast chicken',
      subtitleKey: 'Cart item rice vermicelli subtitle',
      unitPriceEgp: 50,
      quantity: 1,
      imageAsset: _imgFood,
    ),
  ];

  void increment(String id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(quantity: item.quantity + 1) else item,
    ];
  }

  void decrement(String id) {
    final next = <CartLineItem>[];
    for (final item in state) {
      if (item.id != id) {
        next.add(item);
        continue;
      }
      if (item.quantity <= 1) {
        continue;
      }
      next.add(item.copyWith(quantity: item.quantity - 1));
    }
    state = next;
  }

  void clear() {
    state = [];
  }
}

int cartSubtotalEgp(List<CartLineItem> items) {
  return items.fold<int>(
    0,
    (sum, item) => sum + item.unitPriceEgp * item.quantity,
  );
}

int cartCompareAtTotalEgp(int subtotal) {
  if (subtotal <= 0) return 0;
  return subtotal + 50;
}
