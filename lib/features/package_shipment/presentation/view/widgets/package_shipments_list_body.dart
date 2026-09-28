import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/package_shipment/domain/entities/package_shipment_entity.dart';
import 'package:heraj/features/package_shipment/presentation/managers/package_shipment_actions_mixin.dart';
import 'package:heraj/features/package_shipment/presentation/managers/package_shipment_provider.dart';
import 'package:heraj/features/package_shipment/presentation/view/create_package_shipment_screen.dart';
import 'package:heraj/features/package_shipment/presentation/view/package_shipment_details_screen.dart';
import 'package:heraj/features/package_shipment/presentation/view/widgets/package_shipment_shimmers.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';

/// Shared list body for package shipments (orders tab + standalone screen).
class PackageShipmentsListBody extends ConsumerStatefulWidget {
  const PackageShipmentsListBody({
    super.key,
    this.showCreateWhenEmpty = true,
  });

  final bool showCreateWhenEmpty;

  @override
  ConsumerState<PackageShipmentsListBody> createState() =>
      _PackageShipmentsListBodyState();
}

class _PackageShipmentsListBodyState extends ConsumerState<PackageShipmentsListBody>
    with PackageShipmentActionsMixin {
  String _money(double v) {
    final text = v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
    return '$text ${'EGP'.tr}';
  }

  @override
  Widget build(BuildContext context) {
    final shipmentsAsync = ref.watch(fetchMyPackageShipmentsProvider);

    return shipmentsAsync.customWhen(
      ref: ref,
      refreshable: fetchMyPackageShipmentsProvider.future,
      skipLoadingOnRefresh: true,
      loading: () => const PackageShipmentsListShimmer(),
      data: (shipments) {
        if (shipments.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'No package shipments yet'.tr,
                  style: AppFont.font16W600Black,
                  textAlign: TextAlign.center,
                ),
                if (widget.showCreateWhenEmpty) ...[
                  const Gap(16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: CustomFilledButton(
                      text: 'Send a package'.tr,
                      onPressed: () =>
                          Get.to(() => const CreatePackageShipmentScreen()),
                    ),
                  ),
                ],
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(fetchMyPackageShipmentsProvider);
            try {
              await ref.read(fetchMyPackageShipmentsProvider.future);
            } catch (_) {}
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              MediaQuery.paddingOf(context).bottom + 24,
            ),
            itemCount: shipments.length,
            separatorBuilder: (_, __) => const Gap(12),
            itemBuilder: (context, index) {
              final shipment = shipments[index];
              final cancelling = ref.watch(
                isLoadingProvider(
                  PackageShipmentActionsMixin.cancelLoadingKey(
                    shipment.id.toString(),
                  ),
                ),
              );
              return _ShipmentCard(
                shipment: shipment,
                money: _money,
                isCancelling: cancelling,
                onTap: () => Get.to(
                  () => PackageShipmentDetailsScreen(
                    shipmentId: shipment.id.toString(),
                  ),
                ),
                onCancel: shipment.canCancel
                    ? () => cancelPackageShipment(shipment.id.toString())
                    : null,
              );
            },
          ),
        );
      },
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  const _ShipmentCard({
    required this.shipment,
    required this.money,
    required this.isCancelling,
    required this.onTap,
    this.onCancel,
  });

  final PackageShipmentEntity shipment;
  final String Function(double) money;
  final bool isCancelling;
  final VoidCallback onTap;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColor.checkoutBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${shipment.id} · ${shipment.packageSize?.name ?? 'Package'.tr}',
                      style: AppFont.font16W600Black,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      packageShipmentStatusLabel(shipment.status),
                      style: AppFont.font12W600Black.copyWith(
                        color: AppColor.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              Text(shipment.pickupAddress, style: AppFont.font12w400Black),
              const Gap(6),
              Text(
                '${'Dropoffs'.tr}: ${shipment.dropoffs.length} · ${money(shipment.displayPrice)}',
                style: AppFont.font14W500Black,
              ),
              if (shipment.dropoffs.isNotEmpty) ...[
                const Gap(10),
                ...shipment.dropoffs.take(3).map(
                      (d) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${d.sequence}. ${d.receiverName} · ${d.receiverPhone}',
                          style: AppFont.font12w400Black,
                        ),
                      ),
                    ),
              ],
              if (onCancel != null) ...[
                const Gap(12),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: isCancelling ? null : onCancel,
                    child: isCancelling
                        ? const LoadingWidget(size: 18)
                        : Text(
                            'Cancel shipment'.tr,
                            style: AppFont.font14W500Black.copyWith(
                              color: AppColor.danger,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
