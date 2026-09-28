import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/cart/presentation/managers/fetch_cart_provider.dart';
import 'package:heraj/features/orders/domain/use_cases/reorder_order_use_case.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/ui.dart';

mixin OrdersActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  static String reorderLoadingKey(String orderId) => 'reorderOrder_$orderId';

  Future<void> reorderOrder(String orderId) async {
    final loadingKey = OrdersActionsMixin.reorderLoadingKey(orderId);
    ref.read(isLoadingProvider(loadingKey).notifier).state = true;
    try {
      final res = await getIt<ReorderOrderUseCase>().call(orderId);
      await res.fold(
        (l) async {
          UIHelper.showAlert(l.message, type: DialogType.error);
        },
        (_) async {
          ref.invalidate(fetchCartProvider);
          UIHelper.showGlobalSnackBar(
            text:
                'Items were added to your cart. Review quantities before checkout.'
                    .tr,
          );
          if (!mounted) return;
          Get.toNamed('/cart');
        },
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider(loadingKey).notifier).state = false;
      }
    }
  }
}
