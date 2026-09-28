part of '../create_package_shipment_screen.dart';

class _ConfirmStep extends StatelessWidget {
  const _ConfirmStep({
    super.key,
    required this.draft,
    required this.money,
    required this.onSelectPayment,
    required this.onRecalculate,
    required this.isCalculating,
  });

  final PackageShipmentDraft draft;
  final String Function(double) money;
  final ValueChanged<PackageShipmentPaymentMethod> onSelectPayment;
  final Future<bool> Function() onRecalculate;
  final bool isCalculating;

  @override
  Widget build(BuildContext context) {
    final quote = draft.priceQuote;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: 'Payment method'.tr,
          child: Column(
            children: [
              _PaymentTile(
                title: 'Cash on delivery'.tr,
                icon: Icons.payments_outlined,
                selected:
                    draft.paymentMethod == PackageShipmentPaymentMethod.cash,
                onTap: () => onSelectPayment(PackageShipmentPaymentMethod.cash),
              ),
              const Gap(8),
              _PaymentTile(
                title: 'Online payment'.tr,
                icon: Icons.credit_card_outlined,
                selected:
                    draft.paymentMethod == PackageShipmentPaymentMethod.online,
                onTap: () =>
                    onSelectPayment(PackageShipmentPaymentMethod.online),
              ),
            ],
          ),
        ),
        const Gap(12),
        _SectionCard(
          title: 'Price summary'.tr,
          trailing: isCalculating
              ? const LoadingWidget(size: 18)
              : TextButton(
                  onPressed: onRecalculate,
                  child: Text('Refresh'.tr),
                ),
          child: quote == null
              ? Text(
                  'Calculate price to continue'.tr,
                  style: AppFont.font12w400Black,
                )
              : Column(
                  children: [
                    _PriceRow(
                      label: 'Distance'.tr,
                      value: '${quote.distanceKm.toStringAsFixed(2)} km',
                    ),
                    _PriceRow(
                      label: 'Base price'.tr,
                      value: money(quote.basePrice),
                    ),
                    _PriceRow(
                      label: 'Size multiplier'.tr,
                      value: '×${quote.sizeMultiplier.toStringAsFixed(0)}',
                    ),
                    const Divider(height: 20),
                    _PriceRow(
                      label: 'Total'.tr,
                      value: money(quote.totalPrice),
                      bold: true,
                    ),
                    if (quote.routeLegs.isNotEmpty) ...[
                      const Gap(12),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          'Route legs'.tr,
                          style: AppFont.font14W600Black,
                        ),
                      ),
                      const Gap(8),
                      ...quote.routeLegs.map(
                        (leg) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '${'Leg'.tr} ${leg.sequence}: ${leg.distanceKm.toStringAsFixed(2)} km',
                            style: AppFont.font12w400Black,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
        const Gap(12),
        _SectionCard(
          title: 'Summary'.tr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${'Package size'.tr}: ${draft.selectedSize?.name ?? '-'}',
                style: AppFont.font14W500Black,
              ),
              const Gap(6),
              Text(
                '${'Dropoffs'.tr}: ${draft.dropoffs.length}',
                style: AppFont.font14W500Black,
              ),
              const Gap(6),
              Text(
                draft.pickupAddress?.address ?? '',
                style: AppFont.font12w400Black,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
