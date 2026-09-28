import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../../config/app_assets.dart';
import '../../../../config/app_color.dart';
import '../../../../config/app_font.dart';
import '../../../../core/service/loading_provider.dart';
import '../../../../helper/riverpod.dart';
import '../../../../ui/shared_widgets/loading_widget.dart';
import '../../../../ui/shared_widgets/shimmer_effect.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/entities/order_vendor_entity.dart';
import '../manager/order_details_actions_mixin.dart';
import '../manager/orders_actions_mixin.dart';
import '../manager/orders_provider.dart';
import '../../../rating/presentation/managers/rating_actions_mixin.dart';
import 'widgets/order_eta_card.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen>
    with OrdersActionsMixin, RatingActionsMixin, OrderDetailsActionsMixin {
  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(fetchOrderDetailsProvider(widget.orderId));
    final isReordering = ref.watch(
      isLoadingProvider(OrdersActionsMixin.reorderLoadingKey(widget.orderId)),
    );
    final isCancelling = ref.watch(
      isLoadingProvider(
        OrderDetailsActionsMixin.cancelLoadingKey(widget.orderId),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: detailsAsync.customWhen(
          ref: ref,
          skipLoadingOnReload: true,
          skipLoadingOnRefresh: true,
          refreshable: fetchOrderDetailsProvider(widget.orderId).future,
          loading: () => const _OrderDetailsShimmer(),
          data: (details) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Get.back(),
                          borderRadius: BorderRadius.circular(12),
                          child: const SizedBox(
                            width: 24,
                            height: 24,
                            child: Icon(
                              Icons.arrow_back_ios,
                              size: 18,
                              color: Color(0xFF111111),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Order tracking'.tr,
                            style: AppFont.font18W700Black,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 24, height: 24),
                      ],
                    ),
                  ),
                  const Gap(16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OrderEtaCard(
                      entity: details,
                      showTrack: details.canTrack,
                      onTrack: () => onTrackOrder(details.orderId),
                      onPlay: onPlayGames,
                    ),
                  ),
                  const Gap(16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'We will deliver the order to'.tr,
                      style: AppFont.font14W500Black.copyWith(
                        color: const Color(0xFF999999),
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const Gap(12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _DestinationSection(
                      title: details.destinationTitle,
                      address: details.destinationAddress,
                    ),
                  ),
                  const Gap(12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _DeliveryCodeSection(
                      code: details.deliveryCode,
                    ),
                  ),
                  const Gap(12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _YourOrderSection(items: details.items),
                  ),
                  const Gap(12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _PaymentDetailsSection(
                        totalAmount: details.totalAmount),
                  ),
                  const Gap(12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _SupportSection(orderId: details.orderId),
                  ),
                  const Gap(12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _SupportActions(
                      showCancel: details.canCancel,
                      showReorder: details.canReorder,
                      showRate: details.canRate,
                      showRatings: details.hasUserRatings && !details.canRate,
                      showRefundRequest: details.canRequestRefund,
                      isReordering: isReordering,
                      isCancelling: isCancelling,
                      ratedVendors: details.ratedVendors,
                      ratingOutOf5: details.ratingOutOf5,
                      onHelpCenter: onHelpCenter,
                      onCancelOrder: () => onCancelOrder(details.orderId),
                      onRequestRefund: () => onRequestRefund(details.orderId),
                      onReorder: () => reorderOrder(details.orderId),
                      onRate: () => startOrderDetailsRatingFlow(details),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DestinationSection extends StatelessWidget {
  const _DestinationSection({
    required this.title,
    required this.address,
  });

  final String title;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              AppAssets.locationCircle,
              width: 18,
              height: 18,
            ),
            const Gap(4),
            Text(
              title.tr,
              style: AppFont.font18W700Black,
            ),
          ],
        ),
        const Gap(8),
        Text(
          address.tr,
          style: AppFont.font14W500Black.copyWith(
            color: const Color(0xFF111111),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

class _DeliveryCodeSection extends StatelessWidget {
  const _DeliveryCodeSection({required this.code});

  final String? code;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery code'.tr,
          style: AppFont.font14W500Black.copyWith(
            color: const Color(0xFF999999),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.right,
        ),
        const Gap(12),
        Text(
          code ?? '-',
          style: AppFont.font18W700Black,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

class _YourOrderSection extends StatelessWidget {
  const _YourOrderSection({required this.items});

  final List<OrderItemEntity> items;

  @override
  Widget build(BuildContext context) {
    final productItems = items.where((item) => !item.isCustomAddon).toList();
    final addonItems = items.where((item) => item.isCustomAddon).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your order'.tr, style: AppFont.font18W700Black),
        const Gap(8),
        for (var i = 0; i < productItems.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom:
                  i == productItems.length - 1 && addonItems.isEmpty ? 0 : 8,
            ),
            child: _OrderDetailsProductRow(item: productItems[i]),
          ),
        if (addonItems.isNotEmpty) ...[
          const Gap(8),
          Text('Pharmacy addons'.tr,
              style: AppFont.font16W500Black.copyWith(
                fontWeight: FontWeight.w700,
              )),
          const Gap(8),
          for (var i = 0; i < addonItems.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == addonItems.length - 1 ? 0 : 8,
              ),
              child: _OrderDetailsAddonRow(item: addonItems[i]),
            ),
        ],
      ],
    );
  }
}

class _OrderDetailsProductRow extends StatelessWidget {
  const _OrderDetailsProductRow({required this.item});

  final OrderItemEntity item;

  String _formatMoney(double value) {
    final text =
        value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
    return '$text ${'EGP'.tr}';
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final variant = item.variantLabel(languageCode);
    final additions = item.additionsLabel(languageCode);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: AppColor.defaultPrimaryGradient,
            borderRadius: BorderRadius.circular(50),
          ),
          alignment: Alignment.center,
          child: Text(
            '${item.quantity}',
            style: AppFont.font14W500White.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.displayName(languageCode),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppFont.font16W500Black.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (variant.isNotEmpty) ...[
                const Gap(2),
                Text(
                  variant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.font12w500Grey2,
                ),
              ],
              if (additions.isNotEmpty) ...[
                const Gap(2),
                Text(
                  additions,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.font12w500Grey2.copyWith(
                    color: AppColor.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const Gap(8),
        Text(
          _formatMoney(item.price),
          style: AppFont.font14W500Black.copyWith(
            color: AppColor.guestOrange,
          ),
        ),
      ],
    );
  }
}

class _OrderDetailsAddonRow extends StatelessWidget {
  const _OrderDetailsAddonRow({required this.item});

  final OrderItemEntity item;

  String _formatMoney(double value) {
    return '${value.round()} ${'EGP'.tr}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.displayName(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFont.font14W700Black,
              ),
              const Gap(2),
              Text(
                item.addonSubtitle(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFont.font12w500Grey2,
              ),
            ],
          ),
        ),
        const Gap(8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'x${item.quantity}',
              style: AppFont.font12w500Grey2,
            ),
            const Gap(4),
            Text(
              _formatMoney(item.price),
              style: AppFont.font14W500Black.copyWith(
                color: AppColor.guestOrange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PaymentDetailsSection extends StatelessWidget {
  const _PaymentDetailsSection({required this.totalAmount});

  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment details'.tr, style: AppFont.font18W700Black),
        const Gap(8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total amount'.tr,
              style: AppFont.font14W500Black.copyWith(
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.right,
            ),
            Text(
              '${totalAmount.round()} ${'EGP'.tr}',
              style: AppFont.font16W500Black.copyWith(
                color: const Color(0xFFF47621),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SupportSection extends StatelessWidget {
  const _SupportSection({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Support'.tr, style: AppFont.font18W700Black),
        const Gap(8),
        Text(
          'Order number hash'.trParams({'id': orderId}),
          style: AppFont.font14W500Black.copyWith(
            color: const Color(0xFF4D4D4D),
            fontWeight: FontWeight.w400,
          ),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

class _SupportActions extends StatelessWidget {
  const _SupportActions({
    required this.onHelpCenter,
    required this.onCancelOrder,
    required this.onRequestRefund,
    required this.onReorder,
    required this.onRate,
    required this.showCancel,
    required this.showReorder,
    required this.showRate,
    required this.showRatings,
    required this.showRefundRequest,
    required this.isReordering,
    required this.isCancelling,
    required this.ratedVendors,
    required this.ratingOutOf5,
  });

  final VoidCallback onHelpCenter;
  final VoidCallback onCancelOrder;
  final VoidCallback onRequestRefund;
  final VoidCallback onReorder;
  final VoidCallback onRate;
  final bool showCancel;
  final bool showReorder;
  final bool showRate;
  final bool showRatings;
  final bool showRefundRequest;
  final bool isReordering;
  final bool isCancelling;
  final List<OrderVendorEntity> ratedVendors;
  final int ratingOutOf5;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ActionRow(
          title: 'Help center'.tr,
          onTap: onHelpCenter,
        ),
        if (showCancel) ...[
          const Divider(height: 1, color: Color(0xFFE6E6E6)),
          _ActionRow(
            title: 'Cancel order'.tr,
            onTap: isCancelling ? null : onCancelOrder,
            trailing: isCancelling ? const LoadingWidget(size: 18) : null,
          ),
        ],
        if (showRefundRequest) ...[
          const Divider(height: 1, color: Color(0xFFE6E6E6)),
          _ActionRow(
            title: 'Request refund'.tr,
            onTap: onRequestRefund,
          ),
        ],
        if (showReorder) ...[
          const Divider(height: 1, color: Color(0xFFE6E6E6)),
          _ActionRow(
            title: 'Order again'.tr,
            onTap: isReordering ? null : onReorder,
            trailing: isReordering ? const LoadingWidget(size: 18) : null,
          ),
        ],
        if (showRate) ...[
          const Gap(8),
          GestureDetector(
            onTap: onRate,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEBEBEB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Color(0xFFF2C71C), size: 16),
                  const Gap(8),
                  Text(
                    'Rate the order'.tr,
                    style: AppFont.font14W500Black.copyWith(
                      color: const Color(0xFF808080),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else if (showRatings) ...[
          const Gap(8),
          _OrderRatingsCard(
            vendors: ratedVendors,
            averageRating: ratingOutOf5,
          ),
        ],
      ],
    );
  }
}

class _OrderRatingsCard extends StatelessWidget {
  const _OrderRatingsCard({
    required this.vendors,
    required this.averageRating,
  });

  final List<OrderVendorEntity> vendors;
  final int averageRating;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFF2C71C), size: 18),
              const Gap(8),
              Expanded(
                child: Text(
                  'Your ratings'.tr,
                  style: AppFont.font14W700Black,
                ),
              ),
              if (averageRating > 0)
                Text(
                  '$averageRating/5',
                  style: AppFont.font14W500Black.copyWith(
                    color: const Color(0xFF808080),
                  ),
                ),
            ],
          ),
          const Gap(12),
          ...vendors.map((vendor) {
            final rating = vendor.userRating!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor.name.isNotEmpty ? vendor.name : 'Vendor'.tr,
                    style: AppFont.font14W500Black,
                  ),
                  const Gap(4),
                  Row(
                    children: List.generate(5, (index) {
                      final filled = index < rating.ratingOutOf5;
                      return Icon(
                        filled ? Icons.star_rounded : Icons.star_border_rounded,
                        size: 16,
                        color: const Color(0xFFF2C71C),
                      );
                    }),
                  ),
                  if (rating.comment.isNotEmpty) ...[
                    const Gap(4),
                    Text(
                      rating.comment,
                      style: AppFont.font12w500Grey2.copyWith(
                        color: const Color(0xFF808080),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    this.onTap,
    this.trailing,
  });

  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppFont.font16W500Black.copyWith(
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.right,
            ),
            trailing ?? const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }
}

class _OrderDetailsShimmer extends StatelessWidget {
  const _OrderDetailsShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ShimmerEffect(
        enable: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(8),
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECECEC),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECECEC),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 24),
              ],
            ),
            const Gap(16),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFECECEC),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const Gap(16),
            Container(
              width: 160,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFFECECEC),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const Gap(12),
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFECECEC),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const Gap(12),
            Container(
              width: 100,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFFECECEC),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const Gap(12),
            for (int i = 0; i < 3; i++) ...[
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFECECEC),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Gap(8),
            ],
          ],
        ),
      ),
    );
  }
}
