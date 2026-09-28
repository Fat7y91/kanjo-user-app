import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/bundle_order/data/models/bundle_order_model.dart';
import 'package:heraj/features/bundle_order/domain/use_case/create_bundle_from_cart_use_case.dart';
import 'package:heraj/features/bundle_order/domain/use_case/list_my_bundle_orders_use_case.dart';
import 'package:heraj/features/bundle_order/domain/use_case/add_my_cart_to_bundle_use_case.dart';
import 'package:heraj/features/bundle_order/domain/entities/bundle_order_item_entity.dart';
import 'package:heraj/features/bundle_order/domain/use_case/cancel_bundle_order_use_case.dart';
import 'package:heraj/features/bundle_order/domain/use_case/remove_my_bundle_item_use_case.dart';
import 'package:heraj/features/bundle_order/domain/use_case/show_bundle_by_code_use_case.dart';
import 'package:heraj/features/bundle_order/presentation/managers/bundle_order_providers.dart';
import 'package:heraj/features/bundle_order/presentation/view/widgets/active_bundle_order_sheet.dart';
import 'package:heraj/features/bundle_order/presentation/view/widgets/bundle_order_checkout_bottom_sheet.dart';
import 'package:heraj/features/bundle_order/presentation/view/widgets/put_cart_in_bundle_code_sheet.dart';
import 'package:heraj/features/cart/presentation/managers/fetch_cart_provider.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/ui.dart';

mixin CartScreenActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  static const createBundleLoadingKey = 'createBundleOrder';
  static const viewBundleLoadingKey = 'viewBundleOrder';
  static const putInBundleLoadingKey = 'putCartInBundle';
  static String cancelBundleLoadingKey(String code) =>
      'cancelBundleOrder_$code';

  final ValueNotifier<bool> _isCancellingBundle = ValueNotifier<bool>(false);

  Future<void> createBundleOrderFromSwipe() async {
    ref.read(isLoadingProvider(createBundleLoadingKey).notifier).state = true;
    try {
      final res = await getIt<CreateBundleFromCartUseCase>().call(
        const CreateBundleFromCartParams(),
      );
      await res.fold(
        (l) async {
          UIHelper.showAlert(l.message, type: DialogType.error);
        },
        (bundle) async {
          ref.invalidate(fetchCartProvider);
          ref.invalidate(myBundleOrdersProvider);
          if (!mounted) return;
          var shown = bundle;
          if (shown.code.isEmpty || shown.participants.isEmpty) {
            shown = await _firstActiveBundleOrder() ?? shown;
          }
          if (!mounted) return;
          await showActiveBundleOrderSheet(shown);
        },
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider(createBundleLoadingKey).notifier).state =
            false;
      }
    }
  }

  Future<void> openPutCartInBundleByCode() async {
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(90),
      builder: (_) => const PutCartInBundleCodeSheet(),
    );
    if (!mounted) return;
    final trimmed = code?.trim() ?? '';
    if (trimmed.isEmpty) return;
    await putCartInBundle(code: trimmed);
  }

  Future<void> putCartInBundle({String? code}) async {
    final bundleCode = code?.trim() ?? '';
    if (bundleCode.isEmpty) {
      await openPutCartInBundleByCode();
      return;
    }

    ref.read(isLoadingProvider(putInBundleLoadingKey).notifier).state = true;
    try {
      final res = await getIt<AddMyCartToBundleUseCase>().call(bundleCode);
      await res.fold(
        (l) async {
          UIHelper.showAlert(l.message, type: DialogType.error);
        },
        (bundle) async {
          ref.invalidate(fetchCartProvider);
          ref.invalidate(myBundleOrdersProvider);
          if (!mounted) return;

          final codeToShow =
              bundle.code.trim().isNotEmpty ? bundle.code.trim() : bundleCode;
          final byCode =
              await getIt<ShowBundleByCodeUseCase>().call(codeToShow);
          if (!mounted) return;
          final shown = byCode.fold((_) => bundle, (r) => r);
          await showActiveBundleOrderSheet(shown);
        },
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider(putInBundleLoadingKey).notifier).state =
            false;
      }
    }
  }

  Future<void> viewActiveBundleOrder({String? code}) async {
    ref.read(isLoadingProvider(viewBundleLoadingKey).notifier).state = true;
    try {
      final trimmedCode = code?.trim() ?? '';
      BundleOrderModel? bundle;
      if (trimmedCode.isNotEmpty) {
        final byCode = await getIt<ShowBundleByCodeUseCase>().call(trimmedCode);
        bundle = byCode.fold((l) {
          UIHelper.showAlert(l.message, type: DialogType.error);
          return null;
        }, (r) => r);
      }

      bundle ??= await _firstActiveBundleOrder();
      if (bundle == null || !mounted) return;
      await showActiveBundleOrderSheet(bundle);
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider(viewBundleLoadingKey).notifier).state =
            false;
      }
    }
  }

  Future<BundleOrderModel?> _firstActiveBundleOrder() async {
    final res = await getIt<ListMyBundleOrdersUseCase>().call();
    return res.fold(
      (l) {
        UIHelper.showAlert(l.message, type: DialogType.error);
        return null;
      },
      (bundles) {
        if (bundles.isEmpty) {
          UIHelper.showAlert(
            'No active bundle order'.tr,
            type: DialogType.warning,
          );
          return null;
        }
        return bundles.first;
      },
    );
  }

  Future<void> openBundleOrderCheckout(
    BuildContext bundleSheetContext,
    BundleOrderModel bundle,
  ) {
    return showModalBottomSheet<void>(
      context: bundleSheetContext,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(90),
      builder: (checkoutContext) {
        return BundleOrderCheckoutBottomSheet(
          bundle: bundle,
          onSubmitted: () {
            if (bundleSheetContext.mounted) {
              Navigator.of(bundleSheetContext).pop();
            }
          },
        );
      },
    );
  }

  Future<void> cancelBundleOrder(
    BundleOrderModel bundle, {
    BuildContext? sheetContext,
  }) async {
    final code = bundle.code.trim();
    if (code.isEmpty) return;

    final loadingKey = cancelBundleLoadingKey(code);
    if (ref.read(isLoadingProvider(loadingKey))) return;

    ref.read(isLoadingProvider(loadingKey).notifier).state = true;
    _isCancellingBundle.value = true;
    try {
      final res = await getIt<CancelBundleOrderUseCase>().call(code);
      await res.fold(
        (l) async {
          UIHelper.showAlert(l.message, type: DialogType.error);
        },
        (_) async {
          ref.invalidate(fetchCartProvider);
          ref.invalidate(myBundleOrdersProvider);
          if (sheetContext?.mounted == true) {
            Navigator.of(sheetContext!).pop();
          }
          UIHelper.showGlobalSnackBar(
            text: 'Bundle order cancelled successfully'.tr,
          );
          // Ensure cart items restored from cancelled bundle are visible.
          await ref.read(fetchCartProvider.future);
        },
      );
    } finally {
      _isCancellingBundle.value = false;
      if (mounted) {
        ref.read(isLoadingProvider(loadingKey).notifier).state = false;
      }
    }
  }

  final ValueNotifier<int?> _deletingBundleItemId = ValueNotifier<int?>(null);

  Future<void> _deleteBundleItem(
    BundleOrderItemEntity item,
    String bundleCode,
    BuildContext sheetContext,
  ) async {
    _deletingBundleItemId.value = item.id;
    try {
      final res = await getIt<RemoveMyBundleItemUseCase>().call(
        RemoveBundleItemParams(
          bundleCode: bundleCode,
          bundleItemId: item.id,
        ),
      );
      await res.fold(
        (l) async {
          UIHelper.showAlert(l.message, type: DialogType.error);
        },
        (_) async {
          ref.invalidate(myBundleOrdersProvider);
          ref.invalidate(fetchCartProvider);
          if (!mounted) return;
          if (sheetContext.mounted) {
            Navigator.of(sheetContext).pop();
          }
          final refreshed =
              await getIt<ShowBundleByCodeUseCase>().call(bundleCode);
          refreshed.fold(
            (l) => null,
            (updated) {
              if (mounted) showActiveBundleOrderSheet(updated);
            },
          );
        },
      );
    } finally {
      _deletingBundleItemId.value = null;
    }
  }

  Future<void> showActiveBundleOrderSheet(BundleOrderModel bundle) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      scrollControlDisabledMaxHeightRatio: .9,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(90),
      builder: (sheetContext) {
        return ValueListenableBuilder<bool>(
          valueListenable: _isCancellingBundle,
          builder: (context, isCancelling, _) {
            return ActiveBundleOrderSheet(
              bundle: bundle,
              onConfirm: bundle.isHost
                  ? () => openBundleOrderCheckout(sheetContext, bundle)
                  : null,
              onCancel: () => cancelBundleOrder(
                bundle,
                sheetContext: sheetContext,
              ),
              isCancelling: isCancelling,
              onDeleteItem: (item) => _deleteBundleItem(
                item,
                bundle.code,
                sheetContext,
              ),
              deletingItemId: _deletingBundleItemId,
            );
          },
        );
      },
    );
  }
}
