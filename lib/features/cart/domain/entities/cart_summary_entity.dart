import 'cart_applied_offer_entity.dart';
import 'cart_coupon_entity.dart';

class CartSummaryEntity {
  final double subtotal;
  final double productDiscount;
  final double discountedSubtotal;
  final double couponDiscount;
  final double discountAmount;
  final double shippingCost;
  final double shippingDiscount;
  final double finalShipping;
  final double tip;
  final double serviceFee;
  final double cashbackAmount;
  final double vatTotal;
  final double total;
  final double walletBalance;
  final double walletAmount;
  final double amountDue;
  final bool hasOffer;
  final String? couponCode;
  final List<String> couponCodes;
  final List<String> couponErrors;
  final List<CartAppliedOfferEntity> appliedOffers;
  final CartCouponEntity? coupon;
  final List<CartCouponEntity> coupons;

  const CartSummaryEntity({
    required this.subtotal,
    required this.productDiscount,
    required this.discountedSubtotal,
    required this.couponDiscount,
    required this.discountAmount,
    required this.shippingCost,
    required this.shippingDiscount,
    required this.finalShipping,
    required this.tip,
    required this.serviceFee,
    required this.cashbackAmount,
    required this.vatTotal,
    required this.total,
    required this.walletBalance,
    required this.walletAmount,
    required this.amountDue,
    required this.hasOffer,
    this.couponCode,
    this.couponCodes = const [],
    this.couponErrors = const [],
    this.appliedOffers = const [],
    this.coupon,
    this.coupons = const [],
  });

  /// Prefer `coupons[]`, then singular `coupon`.
  List<CartCouponEntity> get displayCoupons {
    if (coupons.isNotEmpty) return coupons;
    final single = coupon;
    if (single != null) return [single];
    return const [];
  }

  String get displayCouponCode {
    if (displayCoupons.isNotEmpty) {
      final codes = displayCoupons
          .map((c) => c.code.trim())
          .where((c) => c.isNotEmpty)
          .toList();
      if (codes.isNotEmpty) return codes.join(', ');
    }
    if (couponCodes.isNotEmpty) return couponCodes.join(', ');
    final code = couponCode?.trim() ?? '';
    if (code.isEmpty || code == 'null') return '';
    return code;
  }

  double get displaySubtotal =>
      discountedSubtotal > 0 ? discountedSubtotal : subtotal;

  /// Cart/home totals exclude delivery; shipping is shown on checkout.
  double get totalWithoutShipping {
    final value = total - finalShipping;
    return value < 0 ? 0 : value;
  }

  double get offerSavingsTotal =>
      appliedOffers.fold<double>(0, (sum, o) => sum + o.savings);

  double get couponDiscountTotal => displayCoupons.fold<double>(
        0,
        (sum, c) => sum + c.discountAmount,
      );

  double get couponShippingDiscountTotal => displayCoupons.fold<double>(
        0,
        (sum, c) => sum + c.shippingDiscount,
      );

  double displayTip(double userTip) => tip > 0 ? tip : userTip;

  /// Payable total: discounted subtotal + delivery + service fee + tip − coupon − reward.
  double payableTotal({
    double userTip = 0,
    double rewardDiscount = 0,
  }) {
    final total = displaySubtotal +
        finalShipping +
        serviceFee +
        displayTip(userTip) -
        couponDiscount -
        rewardDiscount;
    return total < 0 ? 0 : total;
  }

  factory CartSummaryEntity.fromJson(Map<String, dynamic> json) {
    double money(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    List<String> stringList(dynamic value) {
      if (value is! List) return const [];
      return value
          .map((e) {
            if (e is Map) {
              return (e['message'] ?? e['error'] ?? e['code'] ?? e).toString();
            }
            return e.toString();
          })
          .where((s) => s.isNotEmpty && s != 'null')
          .toList();
    }

    CartCouponEntity? parseCoupon(dynamic raw) {
      if (raw is! Map) return null;
      return CartCouponEntity.fromJson(Map<String, dynamic>.from(raw));
    }

    final coupons = (json['coupons'] as List?)
            ?.whereType<Map>()
            .map(
              (e) => CartCouponEntity.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList() ??
        const <CartCouponEntity>[];

    return CartSummaryEntity(
      subtotal: money(json['subtotal']),
      productDiscount: money(json['product_discount']),
      discountedSubtotal: money(json['discounted_subtotal']),
      couponDiscount: money(json['coupon_discount']),
      discountAmount: money(json['discount_amount']),
      shippingCost: money(json['shipping_cost']),
      shippingDiscount: money(json['shipping_discount']),
      finalShipping: money(json['final_shipping']),
      tip: money(json['tip']),
      serviceFee: money(json['service_fee']),
      cashbackAmount: money(json['cashback_amount']),
      vatTotal: money(json['vat_total']),
      total: money(json['total']),
      walletBalance: money(json['wallet_balance']),
      walletAmount: money(json['wallet_amount']),
      amountDue: money(json['amount_due']),
      hasOffer: json['has_offer'] == true,
      couponCode: json['coupon_code']?.toString(),
      couponCodes: stringList(json['coupon_codes']),
      couponErrors: stringList(json['coupon_errors']),
      appliedOffers: (json['applied_offers'] as List?)
              ?.whereType<Map>()
              .map(
                (e) => CartAppliedOfferEntity.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
      coupon: parseCoupon(json['coupon']),
      coupons: coupons,
    );
  }

  Map<String, dynamic> toJson() => {
        'subtotal': subtotal,
        'product_discount': productDiscount,
        'discounted_subtotal': discountedSubtotal,
        'coupon_discount': couponDiscount,
        'discount_amount': discountAmount,
        'shipping_cost': shippingCost,
        'shipping_discount': shippingDiscount,
        'final_shipping': finalShipping,
        'tip': tip,
        'service_fee': serviceFee,
        'cashback_amount': cashbackAmount,
        'vat_total': vatTotal,
        'total': total,
        'wallet_balance': walletBalance,
        'wallet_amount': walletAmount,
        'amount_due': amountDue,
        'has_offer': hasOffer,
        'coupon_code': couponCode,
        'coupon_codes': couponCodes,
        'coupon_errors': couponErrors,
        'applied_offers': appliedOffers.map((e) => e.toJson()).toList(),
        'coupon': coupon?.toJson(),
        'coupons': coupons.map((e) => e.toJson()).toList(),
      };
}
