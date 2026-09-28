import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/address/data/model/address_model.dart';
import 'package:heraj/features/address/presentation/managers/address_provider.dart';
import 'package:heraj/features/cart/data/models/cart_model.dart';
import 'package:heraj/features/cart/domain/entities/checkout_params.dart';
import 'package:heraj/features/cart/domain/use_case/apply_coupon_use_case.dart';
import 'package:heraj/features/cart/domain/use_case/checkout_use_case.dart';
import 'package:heraj/features/cart/presentation/managers/checkout_providers.dart';
import 'package:heraj/features/cart/presentation/managers/fetch_cart_provider.dart';
import 'package:heraj/features/cart/presentation/view/order_success_screen.dart';
import 'package:heraj/features/cart/presentation/view/widgets/checkout_rewards_bottom_sheet.dart';
import 'package:heraj/features/rewards/presentation/managers/rewards_provider.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/ui.dart';
import 'package:intl/intl.dart';

mixin CheckoutActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  static String formatScheduledDeliveryAt(DateTime value) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(value);
  }

  Future<void> ensureDefaultCheckoutAddress() async {
    final current = ref.read(checkoutSelectedAddressProvider);
    if (current != null) return;
    try {
      final addresses = await ref.read(fetchAddressesProvider.future);
      if (!mounted || addresses.isEmpty) return;
      AddressModel? selected;
      for (final address in addresses) {
        if (address.isDefault) {
          selected = address;
          break;
        }
      }
      selected ??= addresses.first;
      ref.read(checkoutSelectedAddressProvider.notifier).state = selected;
    } catch (_) {}
  }

  Future<bool> applyCheckoutCoupon(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      UIHelper.showAlert('Checkout promo placeholder'.tr,
          type: DialogType.warning);
      return false;
    }
    final checkoutCart = ref.read(checkoutCartProvider).valueOrNull;
    if (checkoutCart != null && !checkoutCart.actionsEnabled) {
      final warning = checkoutCart.deliveryWarning;
      if (warning != null) {
        UIHelper.showAlert(warning, type: DialogType.warning);
      }
      return false;
    }
    ref.read(isLoadingProvider('applyCoupon').notifier).state = true;
    try {
      final cart = checkoutCart?.cart;
      final existing = <String>{
        ...ref.read(checkoutCouponCodesProvider),
        ...?cart?.summary.couponCodes.where((c) => c.trim().isNotEmpty),
        if ((cart?.summary.couponCode ?? '').trim().isNotEmpty)
          cart!.summary.couponCode!.trim(),
      };
      existing.add(trimmed);
      final codes = existing.toList();

      // Persist for subsequent GET cart calls: `coupon_codes=["KL-220"]`
      ref.read(checkoutCouponCodesProvider.notifier).state = codes;
      ref.read(checkoutCouponCodeProvider.notifier).state = trimmed;

      final addressId =
          checkoutAddressId(ref.read(checkoutSelectedAddressProvider));
      final res = await getIt<ApplyCouponUseCase>().call(
        ApplyCouponParams(
          couponCodes: codes,
          addressId: addressId,
        ),
      );
      return res.fold(
        (l) {
          UIHelper.showAlert(
            l.message,
            type: isCartDeliveryUnavailable(l)
                ? DialogType.warning
                : DialogType.error,
          );
          return false;
        },
        (updated) {
          final applied = <String>{
            ...updated.summary.couponCodes.where((c) => c.trim().isNotEmpty),
            if ((updated.summary.couponCode ?? '').trim().isNotEmpty)
              updated.summary.couponCode!.trim(),
            ...codes,
          }.toList();
          ref.read(checkoutCouponCodesProvider.notifier).state = applied;
          ref.invalidate(fetchCartProvider);
          ref.invalidate(checkoutCartProvider);
          final errors = updated.summary.couponErrors;
          if (errors.isNotEmpty) {
            UIHelper.showAlert(errors.first, type: DialogType.warning);
            return false;
          }
          UIHelper.showGlobalSnackBar(text: 'Coupon applied'.tr);
          return true;
        },
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider('applyCoupon').notifier).state = false;
      }
    }
  }

  Future<void> openCheckoutRewardsSheet({required double orderAmount}) async {
    final checkoutCart = ref.read(checkoutCartProvider).valueOrNull;
    if (checkoutCart != null && !checkoutCart.actionsEnabled) {
      final warning = checkoutCart.deliveryWarning;
      if (warning != null) {
        UIHelper.showAlert(warning, type: DialogType.warning);
      }
      return;
    }

    ref.invalidate(fetchRewardsCenterProvider);
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return CheckoutRewardsBottomSheet(
          orderAmount: orderAmount,
          selectedRewardId: ref.read(checkoutSelectedRewardProvider)?.id,
          onSelected: (reward) {
            ref.read(checkoutSelectedRewardProvider.notifier).state = reward;
            Navigator.of(sheetContext).pop();
          },
          onCleared: () {
            ref.read(checkoutSelectedRewardProvider.notifier).state = null;
            Navigator.of(sheetContext).pop();
          },
        );
      },
    );
  }

  void clearCheckoutReward() {
    ref.read(checkoutSelectedRewardProvider.notifier).state = null;
  }

  void setCheckoutDeliveryMode(CheckoutDeliveryMode mode) {
    ref.read(checkoutDeliveryModeProvider.notifier).state = mode;
    if (mode == CheckoutDeliveryMode.asap) {
      ref.read(checkoutScheduledDeliveryAtProvider.notifier).state = null;
    }
  }

  Future<void> pickCheckoutScheduledDateTime() async {
    final now = DateTime.now();
    final current = ref.read(checkoutScheduledDeliveryAtProvider);
    final initialDate = current ?? now.add(const Duration(hours: 1));
    final firstDate = DateTime(now.year, now.month, now.day);
    final lastDate = firstDate.add(const Duration(days: 14));

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate)
          ? firstDate
          : (initialDate.isAfter(lastDate) ? lastDate : initialDate),
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (date == null || !mounted) return;

    final initialTime = TimeOfDay.fromDateTime(
      current ?? now.add(const Duration(hours: 1)),
    );
    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (time == null || !mounted) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (!selected.isAfter(DateTime.now())) {
      UIHelper.showAlert(
        'Checkout schedule in past'.tr,
        type: DialogType.warning,
      );
      return;
    }

    ref.read(checkoutDeliveryModeProvider.notifier).state =
        CheckoutDeliveryMode.schedule;
    ref.read(checkoutScheduledDeliveryAtProvider.notifier).state = selected;
  }

  Future<void> submitCheckout(CartModel cart) async {
    final checkoutCart = ref.read(checkoutCartProvider).valueOrNull;
    if (checkoutCart != null && !checkoutCart.actionsEnabled) {
      final warning = checkoutCart.deliveryWarning;
      if (warning != null) {
        UIHelper.showAlert(warning, type: DialogType.warning);
      }
      return;
    }

    final address = ref.read(checkoutSelectedAddressProvider);
    final addressId = checkoutAddressId(address);
    if (addressId == null) {
      UIHelper.showGlobalSnackBar(text: 'Checkout no address'.tr);
      return;
    }

    final deliveryMode = ref.read(checkoutDeliveryModeProvider);
    final scheduledAt = ref.read(checkoutScheduledDeliveryAtProvider);
    final isSchedule = deliveryMode == CheckoutDeliveryMode.schedule;
    if (isSchedule) {
      if (scheduledAt == null) {
        UIHelper.showAlert(
          'Checkout select schedule time'.tr,
          type: DialogType.warning,
        );
        return;
      }
      if (!scheduledAt.isAfter(DateTime.now())) {
        UIHelper.showAlert(
          'Checkout schedule in past'.tr,
          type: DialogType.warning,
        );
        return;
      }
    }

    final notes = ref.read(checkoutNotesProvider).trim();
    final couponCodes = <String>{
      ...ref.read(checkoutCouponCodesProvider),
      ...cart.summary.couponCodes.where((code) => code.trim().isNotEmpty),
      if ((cart.summary.couponCode ?? '').trim().isNotEmpty)
        cart.summary.couponCode!.trim(),
    }.toList();
    final params = CheckoutParams(
      addressId: addressId,
      paymentMethod: ref.read(checkoutPaymentMethodProvider).apiValue,
      vendorId: cart.singleVendorId,
      notes: notes.isEmpty ? null : notes,
      tip: ref.read(checkoutTipAmountProvider),
      rewardId: ref.read(checkoutSelectedRewardProvider)?.id,
      isSchedule: isSchedule,
      scheduledDeliveryAt: isSchedule && scheduledAt != null
          ? formatScheduledDeliveryAt(scheduledAt)
          : null,
      couponCodes: couponCodes,
    );

    ref.read(isLoadingProvider('checkout').notifier).state = true;
    try {
      final res = await getIt<CheckoutUseCase>().call(params);
      await res.fold(
        (failure) async {
          UIHelper.showAlert(
            failure.message,
            type: isCartDeliveryUnavailable(failure)
                ? DialogType.warning
                : DialogType.error,
          );
        },
        (result) async {
          ref.invalidate(fetchCartProvider);
          ref.invalidate(checkoutCartProvider);
          await Get.offAll(
            () => OrderSuccessScreen(orderId: result.orderId ?? ''),
          );
        },
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider('checkout').notifier).state = false;
      }
    }
  }
}
