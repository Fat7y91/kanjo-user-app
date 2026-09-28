import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/package_shipment/domain/entities/package_dropoff_entity.dart';
import 'package:heraj/features/package_shipment/domain/entities/package_shipment_entity.dart';
import 'package:heraj/features/package_shipment/presentation/managers/package_shipment_actions_mixin.dart';
import 'package:heraj/features/package_shipment/presentation/managers/package_shipment_provider.dart';
import 'package:heraj/features/package_shipment/presentation/view/widgets/package_shipment_shimmers.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';

class PackageShipmentDetailsScreen extends ConsumerStatefulWidget {
  const PackageShipmentDetailsScreen({
    super.key,
    required this.shipmentId,
  });

  final String shipmentId;

  @override
  ConsumerState<PackageShipmentDetailsScreen> createState() =>
      _PackageShipmentDetailsScreenState();
}

class _PackageShipmentDetailsScreenState
    extends ConsumerState<PackageShipmentDetailsScreen>
    with PackageShipmentActionsMixin {
  String _money(double v) {
    final text = v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
    return '$text ${'EGP'.tr}';
  }

  String _paymentLabel(String method) {
    return switch (method) {
      'cod' => 'Cash on delivery'.tr,
      'online' => 'Online payment'.tr,
      _ => method,
    };
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync =
        ref.watch(fetchPackageShipmentDetailsProvider(widget.shipmentId));
    final isCancelling = ref.watch(
      isLoadingProvider(
        PackageShipmentActionsMixin.cancelLoadingKey(widget.shipmentId),
      ),
    );

    return Scaffold(
      backgroundColor: AppColor.pageBackgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: Text(
          'Package shipment details'.tr,
          style: AppFont.font16W700Black,
        ),
      ),
      body: detailsAsync.customWhen(
        ref: ref,
        refreshable:
            fetchPackageShipmentDetailsProvider(widget.shipmentId).future,
        skipLoadingOnReload: true,
        skipLoadingOnRefresh: true,
        loading: () => const PackageShipmentDetailsShimmer(),
        data: (shipment) {
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(
                      fetchPackageShipmentDetailsProvider(widget.shipmentId),
                    );
                    await ref.read(
                      fetchPackageShipmentDetailsProvider(widget.shipmentId)
                          .future,
                    );
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      _HeaderCard(shipment: shipment, money: _money),
                      const Gap(12),
                      _SectionCard(
                        title: 'Pickup address'.tr,
                        child: _InfoRow(
                          icon: Icons.my_location_rounded,
                          title: shipment.pickupAddress,
                          subtitle:
                              '${shipment.pickupLat.toStringAsFixed(5)}, ${shipment.pickupLng.toStringAsFixed(5)}',
                        ),
                      ),
                      const Gap(12),
                      _SectionCard(
                        title: 'Dropoffs'.tr,
                        child: Column(
                          children: [
                            for (var i = 0;
                                i < shipment.dropoffs.length;
                                i++) ...[
                              if (i > 0) const Gap(10),
                              _DropoffCard(dropoff: shipment.dropoffs[i]),
                            ],
                          ],
                        ),
                      ),
                      const Gap(12),
                      _SectionCard(
                        title: 'Price summary'.tr,
                        child: Column(
                          children: [
                            _PriceRow(
                              label: 'Distance'.tr,
                              value:
                                  '${shipment.distanceKm.toStringAsFixed(2)} km',
                            ),
                            _PriceRow(
                              label: 'Base price'.tr,
                              value: _money(shipment.basePrice),
                            ),
                            if (shipment.packageSize != null)
                              _PriceRow(
                                label: 'Size multiplier'.tr,
                                value:
                                    '×${shipment.packageSize!.sizeMultiplier.toStringAsFixed(0)}',
                              ),
                            const Divider(height: 20),
                            _PriceRow(
                              label: 'Total'.tr,
                              value: _money(shipment.displayPrice),
                              bold: true,
                            ),
                          ],
                        ),
                      ),
                      const Gap(12),
                      _SectionCard(
                        title: 'Payment method'.tr,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _paymentLabel(shipment.paymentMethod),
                              style: AppFont.font14W600Black,
                            ),
                            const Gap(6),
                            Text(
                              '${'Payment status'.tr}: ${packageShipmentPaymentStatusLabel(shipment.paymentStatus)}',
                              style: AppFont.font12w400Black,
                            ),
                          ],
                        ),
                      ),
                      if (shipment.packageImageUrl != null &&
                          shipment.packageImageUrl!.trim().isNotEmpty) ...[
                        const Gap(12),
                        _SectionCard(
                          title: 'Package photo'.tr,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: AspectRatio(
                              aspectRatio: 16 / 10,
                              child: ImageOrSvg(
                                shipment.packageImageUrl!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (shipment.canCancel)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: CustomFilledButton(
                      text: 'Cancel shipment'.tr,
                      color: AppColor.danger,
                      isLoading: isCancelling,
                      onPressed: isCancelling
                          ? null
                          : () => cancelPackageShipment(widget.shipmentId),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.shipment,
    required this.money,
  });

  final PackageShipmentEntity shipment;
  final String Function(double) money;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  style: AppFont.font16W700Black,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          Text(
            money(shipment.displayPrice),
            style: AppFont.font16W700Black.copyWith(color: AppColor.primary),
          ),
          if (shipment.packageSize != null) ...[
            const Gap(6),
            Text(
              shipment.packageSize!.dimensionsLabel,
              style: AppFont.font12w400Black,
            ),
          ],
        ],
      ),
    );
  }
}

class _DropoffCard extends StatelessWidget {
  const _DropoffCard({required this.dropoff});

  final PackageDropoffEntity dropoff;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.checkoutBorder),
        color: AppColor.pageBackgroundGrey,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColor.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${dropoff.sequence}',
              style: AppFont.font12W600Black.copyWith(color: AppColor.primary),
            ),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dropoff.receiverName, style: AppFont.font14W600Black),
                const Gap(4),
                Text(dropoff.receiverPhone, style: AppFont.font12w400Black),
                const Gap(4),
                Text(
                  dropoff.dropoffAddress.isNotEmpty
                      ? dropoff.dropoffAddress
                      : '${dropoff.dropoffLat.toStringAsFixed(4)}, ${dropoff.dropoffLng.toStringAsFixed(4)}',
                  style: AppFont.font12w400Black,
                ),
                const Gap(4),
                Text(
                  packageShipmentStatusLabel(dropoff.status),
                  style: AppFont.font12W600Black.copyWith(
                    color: AppColor.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColor.primary, size: 20),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppFont.font14W500Black),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const Gap(4),
                Text(subtitle!, style: AppFont.font12w400Black),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold ? AppFont.font16W700Black : AppFont.font14W500Black;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.checkoutBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppFont.font16W700Black),
          const Gap(12),
          child,
        ],
      ),
    );
  }
}
