import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/package_shipment/domain/entities/package_dropoff_input.dart';
import 'package:heraj/features/package_shipment/domain/entities/package_size_entity.dart';
import 'package:heraj/features/package_shipment/presentation/managers/package_shipment_actions_mixin.dart';
import 'package:heraj/features/package_shipment/presentation/managers/package_shipment_provider.dart';
import 'package:heraj/features/package_shipment/presentation/view/my_package_shipments_screen.dart';
import 'package:heraj/features/package_shipment/presentation/view/widgets/package_shipment_shimmers.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/custom_outlined_button.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:heraj/ui/ui.dart';

part 'widgets/create_package_shipment_shared_widgets.dart';
part 'widgets/create_package_shipment_step_indicator.dart';
part 'widgets/create_package_shipment_size_step.dart';
part 'widgets/create_package_shipment_locations_step.dart';
part 'widgets/create_package_shipment_confirm_step.dart';

class CreatePackageShipmentScreen extends ConsumerStatefulWidget {
  const CreatePackageShipmentScreen({super.key});

  @override
  ConsumerState<CreatePackageShipmentScreen> createState() =>
      _CreatePackageShipmentScreenState();
}

class _CreatePackageShipmentScreenState
    extends ConsumerState<CreatePackageShipmentScreen>
    with PackageShipmentActionsMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ensureDefaultPickupAddress();
    });
  }

  String _money(double v) {
    final text = v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
    return '$text ${'EGP'.tr}';
  }

  Future<void> _goNext() async {
    final draft = ref.read(packageShipmentDraftProvider);
    final notifier = ref.read(packageShipmentDraftProvider.notifier);
    if (draft.step == 0) {
      if (draft.selectedSize == null) {
        UIHelper.showAlert(
          'Please select a package size'.tr,
          type: DialogType.warning,
        );
        return;
      }
      notifier.setStep(1);
      return;
    }
    if (draft.step == 1) {
      if (draft.pickupAddress?.latitude == null ||
          draft.pickupAddress?.longitude == null) {
        await pickPickupAddress();
        return;
      }
      if (draft.dropoffs.isEmpty) {
        final dropoff = await pickDropoffOnMap();
        if (dropoff != null) {
          notifier.addDropoff(dropoff);
        }
        return;
      }
      final ok = await calculatePackagePrice();
      if (ok) notifier.setStep(2);
      return;
    }
    await createPackageShipment();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(packageShipmentDraftProvider);
    final isCalculating = ref.watch(
      isLoadingProvider(PackageShipmentActionsMixin.calculateLoadingKey),
    );
    final isCreating = ref.watch(
      isLoadingProvider(PackageShipmentActionsMixin.createLoadingKey),
    );

    final titles = [
      'Select package size'.tr,
      'Pickup & dropoffs'.tr,
      'Payment & confirm'.tr,
    ];

    return Scaffold(
      backgroundColor: AppColor.pageBackgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            if (draft.step > 0) {
              ref
                  .read(packageShipmentDraftProvider.notifier)
                  .setStep(draft.step - 1);
            } else {
              Get.back();
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: Text(titles[draft.step], style: AppFont.font16W700Black),
        actions: [
          TextButton(
            onPressed: () => Get.to(() => const MyPackageShipmentsScreen()),
            child: Text(
              'My package shipments'.tr,
              style: AppFont.font12W600Primary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _StepIndicator(current: draft.step),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: switch (draft.step) {
                0 => _SizeStep(
                    key: const ValueKey('size'),
                    selectedId: draft.selectedSize?.id,
                    onSelect: (size) => ref
                        .read(packageShipmentDraftProvider.notifier)
                        .selectSize(size),
                  ),
                1 => _LocationsStep(
                    key: const ValueKey('locations'),
                    draft: draft,
                    onPickPickup: pickPickupAddress,
                    onAddDropoff: () async {
                      final dropoff = await pickDropoffOnMap();
                      if (dropoff != null) {
                        ref
                            .read(packageShipmentDraftProvider.notifier)
                            .addDropoff(dropoff);
                      }
                    },
                    onEditDropoff: (index, existing) async {
                      final updated =
                          await pickDropoffOnMap(existing: existing);
                      if (updated != null) {
                        ref
                            .read(packageShipmentDraftProvider.notifier)
                            .updateDropoff(index, updated);
                      }
                    },
                    onRemoveDropoff: (index) {
                      ref
                          .read(packageShipmentDraftProvider.notifier)
                          .removeDropoff(index);
                    },
                    onPickImage: pickPackageImage,
                    onClearImage: () {
                      ref
                          .read(packageShipmentDraftProvider.notifier)
                          .setPackageImage(null);
                    },
                  ),
                _ => _ConfirmStep(
                    key: const ValueKey('confirm'),
                    draft: draft,
                    money: _money,
                    onSelectPayment: (method) {
                      ref
                          .read(packageShipmentDraftProvider.notifier)
                          .setPaymentMethod(method);
                    },
                    onRecalculate: calculatePackagePrice,
                    isCalculating: isCalculating,
                  ),
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: CustomFilledButton(
                text: draft.step == 2
                    ? 'Confirm shipment'.tr
                    : draft.step == 1
                        ? 'Calculate price'.tr
                        : 'Continue'.tr,
                isLoading: isCalculating || isCreating,
                onPressed: (isCalculating || isCreating) ? null : _goNext,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
