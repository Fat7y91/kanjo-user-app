import '../../../../config/api_path.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../../domain/entities/checkout_params.dart';
import '../models/cart_model.dart';

abstract class CartDataSource {
  Future<CartModel> getCart({
    int? addressId,
    List<String>? couponCodes,
  });

  Future<bool> addToCart({
    required int productId,
    int? productVariantId,
    List<int>? additionIds,
    required int quantity,
  });

  Future<bool> updateCartItemQuantity({
    required int cartItemId,
    required int quantity,
  });

  Future<bool> removeFromCart(int cartItemId);

  Future<CartModel> applyCoupon({
    required List<String> couponCodes,
    int? addressId,
    int? vendorId,
  });

  Future<CheckoutResult> checkout(CheckoutParams params);
}

class CartDataSourceImpl extends CartDataSource {
  final ApiService apiService;

  CartDataSourceImpl({required this.apiService});

  @override
  Future<CartModel> getCart({
    int? addressId,
    List<String>? couponCodes,
  }) async {
    final codes = couponCodes
            ?.map((c) => c.trim())
            .where((c) => c.isNotEmpty)
            .toList() ??
        const <String>[];
    final query = <String, dynamic>{
      if (addressId != null) 'address_id': addressId,
      if (codes.isNotEmpty) 'coupon_codes': codes,
    };

    final res = await apiService.get(
      url: ApiPath.getCartItems,
      queryParameters: query.isEmpty ? null : query,
      returnDataOnly: true,
    );

    if (res is Map) {
      return CartModel.fromJson(Map<String, dynamic>.from(res));
    }
    return CartModel.fromJson(const <String, dynamic>{});
  }

  @override
  Future<bool> addToCart({
    required int productId,
    int? productVariantId,
    List<int>? additionIds,
    required int quantity,
  }) async {
    final body = <String, dynamic>{
      'product_id': productId,
      'product_variant_id': productVariantId,
      'quantity': quantity,
    };
    if (additionIds != null && additionIds.isNotEmpty) {
      body['addition_ids'] = additionIds;
    }

    await apiService.post(
      url: ApiPath.addToCart,
      requestBody: body,
      returnDataOnly: true,
    );
    return true;
  }

  @override
  Future<bool> updateCartItemQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    await apiService.post(
      url: ApiPath.updateCartItem,
      requestBody: {
        'cart_item_id': cartItemId,
        'quantity': quantity,
      },
      returnDataOnly: true,
    );
    return true;
  }

  @override
  Future<bool> removeFromCart(int cartItemId) async {
    await apiService.delete(
      url: ApiPath.deleteFromCart(cartItemId.toString()),
    );
    return true;
  }

  @override
  Future<CartModel> applyCoupon({
    required List<String> couponCodes,
    int? addressId,
    int? vendorId,
  }) async {
    final body = <String, dynamic>{
      'coupon_codes': couponCodes,
      'vendor_id': vendorId,
    };
    if (addressId != null) {
      body['address_id'] = addressId;
    }

    await apiService.post(
      url: ApiPath.applyCoupon,
      requestBody: body,
    );

    return getCart(addressId: addressId, couponCodes: couponCodes);
  }

  @override
  Future<CheckoutResult> checkout(CheckoutParams params) async {
    final res = await apiService.post(
      url: ApiPath.checkoutOrder,
      requestBody: params.toJson(),
      returnDataOnly: false,
    );
    if (res is Map) {
      return CheckoutResult.fromJson(Map<String, dynamic>.from(res));
    }
    return const CheckoutResult();
  }
}
