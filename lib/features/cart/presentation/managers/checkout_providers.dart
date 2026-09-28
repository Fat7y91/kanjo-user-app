import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/core/errors/failure.dart';
import 'package:heraj/features/address/data/model/address_model.dart';
import 'package:heraj/features/cart/data/models/cart_model.dart';
import 'package:heraj/features/cart/domain/use_case/fetch_cart_use_case.dart';
import 'package:heraj/features/rewards/data/models/reward_model.dart';
import 'package:heraj/main.dart';

class CheckoutCartState {
  final CartModel cart;
  final String? deliveryWarning;

  const CheckoutCartState({
    required this.cart,
    this.deliveryWarning,
  });

  bool get actionsEnabled => deliveryWarning == null;
}

bool isCartDeliveryUnavailable(Object error) {
  final message = error is Failure ? error.message : error.toString();
  final normalized = message.toLowerCase();
  return normalized.contains('delivery is not available') ||
      normalized.contains('choose another address') ||
      normalized.contains('التوصيل غير متاح');
}

enum CheckoutPaymentMethod {
  cash;

  String get apiValue => switch (this) {
        CheckoutPaymentMethod.cash => 'cod',
      };
}

enum CheckoutDeliveryMode {
  asap,
  schedule,
}

final checkoutPaymentMethodProvider =
    StateProvider.autoDispose<CheckoutPaymentMethod>(
  (ref) => CheckoutPaymentMethod.cash,
);

final checkoutDeliveryModeProvider =
    StateProvider.autoDispose<CheckoutDeliveryMode>(
  (ref) => CheckoutDeliveryMode.asap,
);

final checkoutScheduledDeliveryAtProvider =
    StateProvider.autoDispose<DateTime?>((ref) => null);

final checkoutSelectedAddressProvider =
    StateProvider.autoDispose<AddressModel?>((ref) => null);

final checkoutTipAmountProvider =
    StateProvider.autoDispose<double>((ref) => 0);

final checkoutNotesProvider =
    StateProvider.autoDispose<String>((ref) => '');

final checkoutCouponCodeProvider =
    StateProvider.autoDispose<String>((ref) => '');

/// Codes sent as `coupon_codes` on GET cart while on checkout.
final checkoutCouponCodesProvider =
    StateProvider.autoDispose<List<String>>((ref) => const []);

final checkoutSelectedRewardProvider =
    StateProvider.autoDispose<RewardModel?>((ref) => null);

int? checkoutAddressId(AddressModel? address) {
  final raw = address?.id.trim() ?? '';
  if (raw.isEmpty) return null;
  return int.tryParse(raw);
}

final checkoutCartProvider =
    FutureProvider.autoDispose<CheckoutCartState>((ref) async {
  final useCase = getIt<FetchCartUseCase>();
  final addressId =
      checkoutAddressId(ref.watch(checkoutSelectedAddressProvider));
  final couponCodes = ref.watch(checkoutCouponCodesProvider);
  final res = await useCase.call(
    FetchCartParams(
      addressId: addressId,
      couponCodes: couponCodes,
    ),
  );
  final value = res.fold<Object>((l) => l, (r) => r);
  if (value is CartModel) {
    return CheckoutCartState(cart: value);
  }

  final failure = value as Failure;
  if (addressId == null || !isCartDeliveryUnavailable(failure)) {
    throw failure;
  }

  final fallback = await useCase.call(
    FetchCartParams(couponCodes: couponCodes),
  );
  return fallback.fold(
    (fallbackFailure) => throw fallbackFailure,
    (cart) => CheckoutCartState(
      cart: cart,
      deliveryWarning: failure.message,
    ),
  );
});
