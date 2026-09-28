import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/orders/domain/entities/order_details_entity.dart';
import 'package:heraj/features/orders/domain/entities/order_entity.dart';
import 'package:heraj/features/orders/domain/entities/order_vendor_entity.dart';
import 'package:heraj/features/orders/presentation/manager/orders_provider.dart';
import 'package:heraj/features/rating/domain/entities/rating_params_entity.dart';
import 'package:heraj/features/rating/domain/use_case/rate_delivery_partner_use_case.dart';
import 'package:heraj/features/rating/domain/use_case/rate_vendor_use_case.dart';
import 'package:heraj/features/rating/presentation/view/widgets/rating_bottom_sheet.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/ui.dart';

mixin RatingActionsMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  Future<void> startOrderRatingFlow(OrderEntity order) {
    return startVendorsThenDeliveryRating(
      orderId: order.id,
      vendors: order.unratedVendors,
      deliveryPartnerId: order.deliveryPartnerId,
      deliveryPartnerName: order.deliveryPartnerName,
    );
  }

  Future<void> startOrderDetailsRatingFlow(OrderDetailsEntity details) {
    return startVendorsThenDeliveryRating(
      orderId: details.orderId,
      vendors: details.unratedVendors,
      deliveryPartnerId: details.deliveryPartnerId,
      deliveryPartnerName: details.deliveryPartnerName,
    );
  }

  /// Rates each unrated vendor in order, then the delivery partner.
  Future<void> startVendorsThenDeliveryRating({
    required String orderId,
    required List<OrderVendorEntity> vendors,
    required int deliveryPartnerId,
    required String deliveryPartnerName,
  }) async {
    if (vendors.isEmpty && deliveryPartnerId <= 0) {
      UIHelper.showAlert(
        'Unable to rate this order'.tr,
        type: DialogType.warning,
      );
      return;
    }

    var didSubmit = false;

    for (var i = 0; i < vendors.length; i++) {
      final vendor = vendors[i];
      final submitted = await _showRatingSheet(
        kind: RatingSheetKind.vendor,
        name: vendor.name,
        loadingKey: 'rateVendor_${orderId}_${vendor.id}',
        onSubmit: (rating, comment) {
          return _submitVendorRating(
            vendorId: vendor.id,
            rating: rating,
            comment: comment,
            loadingKey: 'rateVendor_${orderId}_${vendor.id}',
          );
        },
      );
      if (!mounted || submitted != true) {
        if (didSubmit) await _refreshOrderAfterRating(orderId);
        return;
      }
      didSubmit = true;
      await Future<void>.delayed(const Duration(milliseconds: 180));
      if (!mounted) return;
    }

    if (deliveryPartnerId > 0) {
      final submitted = await _showRatingSheet(
        kind: RatingSheetKind.delivery,
        name: deliveryPartnerName,
        loadingKey: 'rateDelivery_$orderId',
        onSubmit: (rating, comment) {
          return _submitDeliveryRating(
            deliveryPartnerId: deliveryPartnerId,
            rating: rating,
            comment: comment,
            loadingKey: 'rateDelivery_$orderId',
          );
        },
      );
      if (submitted == true) didSubmit = true;
    }

    if (didSubmit) await _refreshOrderAfterRating(orderId);
  }

  Future<void> _refreshOrderAfterRating(String orderId) async {
    if (!mounted) return;
    ref.invalidate(fetchOrderDetailsProvider(orderId));
    ref.invalidate(fetchMyOrdersProvider);
    try {
      final orders = await ref.read(fetchMyOrdersProvider.future);
      if (!mounted) return;
      final details =
          await ref.read(fetchOrderDetailsProvider(orderId).future);
      if (!mounted) return;
      final index = orders.indexWhere((order) => order.id == orderId);
      if (index < 0) return;
      final existing = orders[index];
      ref.read(fetchMyOrdersProvider.notifier).upsertOrder(
            existing.copyWith(
              ratingOutOf5: details.ratingOutOf5,
              assignedVendors: details.vendors,
              deliveryPartnerId: details.deliveryPartnerId,
              deliveryPartnerName: details.deliveryPartnerName,
            ),
          );
    } catch (_) {}
  }

  Future<bool?> _showRatingSheet({
    required RatingSheetKind kind,
    required String name,
    required String loadingKey,
    required Future<bool> Function(int rating, String comment) onSubmit,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return RatingBottomSheet(
          kind: kind,
          name: name,
          loadingKey: loadingKey,
          onSubmit: onSubmit,
        );
      },
    );
  }

  Future<bool> _submitVendorRating({
    required int vendorId,
    required int rating,
    required String comment,
    required String loadingKey,
  }) async {
    ref.read(isLoadingProvider(loadingKey).notifier).state = true;
    try {
      final res = await getIt<RateVendorUseCase>().call(
        RatingParamsEntity(
          targetId: vendorId,
          rating: rating,
          comment: comment,
        ),
      );
      return res.fold(
        (l) {
          UIHelper.showAlert(l.message, type: DialogType.error);
          return false;
        },
        (_) {
          UIHelper.showGlobalSnackBar(text: 'Rating submitted'.tr);
          return true;
        },
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider(loadingKey).notifier).state = false;
      }
    }
  }

  Future<bool> _submitDeliveryRating({
    required int deliveryPartnerId,
    required int rating,
    required String comment,
    required String loadingKey,
  }) async {
    ref.read(isLoadingProvider(loadingKey).notifier).state = true;
    try {
      final res = await getIt<RateDeliveryPartnerUseCase>().call(
        RatingParamsEntity(
          targetId: deliveryPartnerId,
          rating: rating,
          comment: comment,
        ),
      );
      return res.fold(
        (l) {
          UIHelper.showAlert(l.message, type: DialogType.error);
          return false;
        },
        (_) {
          UIHelper.showGlobalSnackBar(text: 'Rating submitted'.tr);
          return true;
        },
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider(loadingKey).notifier).state = false;
      }
    }
  }
}
