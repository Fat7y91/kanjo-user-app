class CheckoutParams {
  const CheckoutParams({
    required this.addressId,
    required this.paymentMethod,
    this.vendorId,
    this.notes,
    this.tip,
    this.rewardId,
    this.isSchedule = false,
    this.scheduledDeliveryAt,
    this.couponCodes = const [],
  });

  final int addressId;
  final String paymentMethod;
  final int? vendorId;
  final String? notes;
  final double? tip;
  final int? rewardId;
  final bool isSchedule;
  /// API format: `yyyy-MM-dd HH:mm:ss`
  final String? scheduledDeliveryAt;
  final List<String> couponCodes;

  bool get isSingleVendor => vendorId != null && vendorId! > 0;

  factory CheckoutParams.fromJson(Map<String, dynamic> json) {
    return CheckoutParams(
      addressId: json['address_id'] is int
          ? json['address_id'] as int
          : int.tryParse(json['address_id']?.toString() ?? '') ?? 0,
      paymentMethod: json['payment_method']?.toString() ?? 'cod',
      vendorId: json['vendor_id'] is int
          ? json['vendor_id'] as int
          : int.tryParse(json['vendor_id']?.toString() ?? ''),
      notes: json['notes']?.toString(),
      tip: json['tip'] is num
          ? (json['tip'] as num).toDouble()
          : double.tryParse(json['tip']?.toString() ?? ''),
      rewardId: json['reward_id'] is int
          ? json['reward_id'] as int
          : int.tryParse(json['reward_id']?.toString() ?? ''),
      isSchedule: json['is_schedule'] == true ||
          json['is_schedule']?.toString() == '1' ||
          json['is_schedule']?.toString().toLowerCase() == 'true',
      scheduledDeliveryAt: json['scheduled_delivery_at']?.toString(),
      couponCodes: (json['coupon_codes'] as List?)
              ?.map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    final scheduleFields = <String, dynamic>{
      'is_schedule': isSchedule,
      if (isSchedule) 'scheduled_delivery_at': scheduledDeliveryAt,
    };

    if (isSingleVendor) {
      return {
        'address_id': addressId,
        'vendor_id': vendorId,
        'notes': notes,
        'payment_method': paymentMethod,
        'reward_id': rewardId,
        'tip': tip ?? 0,
        'coupon_codes': couponCodes,
        ...scheduleFields,
      };
    }
    return {
      'address_id': addressId,
      'notes': notes,
      'tip': tip ?? 0,
      'payment_method': paymentMethod,
      'reward_id': rewardId,
      'coupon_codes': couponCodes,
      ...scheduleFields,
    };
  }
}

class CheckoutResult {
  const CheckoutResult({
    this.orderId,
    this.message = '',
  });

  final String? orderId;
  final String message;

  factory CheckoutResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    String? id = data['id']?.toString() ??
        data['order_id']?.toString() ??
        (data['order'] is Map
            ? (data['order'] as Map)['id']?.toString()
            : null);
    if (id == null || id.isEmpty) {
      final orders = data['orders'];
      if (orders is List && orders.isNotEmpty && orders.first is Map) {
        id = (orders.first as Map)['id']?.toString();
      }
    }
    return CheckoutResult(
      orderId: (id == null || id.isEmpty || id == 'null') ? null : id,
      message: json['message']?.toString() ?? data['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'message': message,
      };
}
