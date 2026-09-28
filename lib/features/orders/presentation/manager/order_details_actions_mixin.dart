import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/image_picker_cropper.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/orders/domain/entities/create_refund_request_params.dart';
import 'package:heraj/features/orders/domain/use_cases/cancel_order_use_case.dart';
import 'package:heraj/features/orders/domain/use_cases/create_refund_request_use_case.dart';
import 'package:heraj/features/orders/presentation/manager/orders_provider.dart';
import 'package:heraj/features/orders/presentation/view/widgets/refund_request_sheet.dart';
import 'package:heraj/features/support_tickets/presentation/view/support_tickets_screen.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/ui.dart';

mixin OrderDetailsActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  static String cancelLoadingKey(String orderId) => 'cancelOrder_$orderId';

  void onTrackOrder(String orderId) {
    Get.toNamed('/track-order', arguments: {'id': orderId});
  }

  void onPlayGames() {
    Get.toNamed('/games');
  }

  void onHelpCenter() {
    Get.to(() => const SupportTicketsScreen());
  }

  Future<void> onCancelOrder(String orderId) async {
    final loadingKey = OrderDetailsActionsMixin.cancelLoadingKey(orderId);
    if (ref.read(isLoadingProvider(loadingKey))) return;

    ref.read(isLoadingProvider(loadingKey).notifier).state = true;
    try {
      final result = await getIt<CancelOrderUseCase>().call(orderId);
      await result.fold(
        (failure) async {
          UIHelper.showAlert(failure.message, type: DialogType.error);
        },
        (_) async {
          ref.invalidate(fetchOrderDetailsProvider(orderId));
          ref.invalidate(fetchMyOrdersProvider);
          UIHelper.showGlobalSnackBar(text: 'Order cancelled successfully'.tr);
        },
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider(loadingKey).notifier).state = false;
      }
    }
  }

  Future<void> onRequestRefund(String orderId) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return RefundRequestSheet(
          orderId: orderId,
          onPickImage: () => getIt<ImagePickerService>().pickImage(crop: false),
          onSubmit: (reason, images) => _submitRefundRequest(
            orderId: orderId,
            reason: reason,
            images: images,
          ),
        );
      },
    );
  }

  Future<bool> _submitRefundRequest({
    required String orderId,
    required String reason,
    required List<File> images,
  }) async {
    const loadingKey = RefundRequestSheet.loadingKey;
    ref.read(isLoadingProvider(loadingKey).notifier).state = true;
    try {
      final result = await getIt<CreateRefundRequestUseCase>().call(
        CreateRefundRequestParams(
          orderId: orderId,
          reason: reason,
          images: images,
        ),
      );
      return await result.fold(
        (failure) async {
          UIHelper.showAlert(failure.message, type: DialogType.error);
          return false;
        },
        (_) async {
          ref.invalidate(fetchOrderDetailsProvider(orderId));
          UIHelper.showGlobalSnackBar(
            text: 'Refund request submitted successfully'.tr,
          );
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
