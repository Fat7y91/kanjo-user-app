import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/orders/domain/entities/order_entity.dart';
import 'package:heraj/features/orders/domain/entities/order_item_entity.dart';
import 'package:heraj/features/orders/presentation/manager/orders_actions_mixin.dart';
import 'package:heraj/features/orders/presentation/manager/orders_provider.dart';
import 'package:heraj/features/orders/presentation/view/widgets/orders_empty.dart';
import 'package:heraj/features/orders/presentation/view/widgets/orders_shimmer.dart';
import 'package:heraj/features/rating/presentation/managers/rating_actions_mixin.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:intl/intl.dart';

class MyOrdersTab extends ConsumerStatefulWidget {
  const MyOrdersTab({
    super.key,
    this.scheduledOnly = false,
  });

  /// When true, only scheduled product orders are shown.
  /// When false, only non-scheduled product orders are shown.
  final bool scheduledOnly;

  @override
  ConsumerState<MyOrdersTab> createState() => _MyOrdersTabState();
}

class _MyOrdersTabState extends ConsumerState<MyOrdersTab>
    with RatingActionsMixin, OrdersActionsMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) {
      return;
    }
    final notifier = ref.read(fetchMyOrdersProvider.notifier);
    if (notifier.isLastPage()) return;
    notifier.fetchNextPage();
  }

  List<OrderEntity> _filterOrders(List<OrderEntity> orders) {
    return orders
        .where(
          (order) => widget.scheduledOnly
              ? order.isScheduledOrder
              : !order.isScheduledOrder,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(fetchMyOrdersProvider);

    return ordersAsync.customWhen(
      ref: ref,
      refreshable: fetchMyOrdersProvider.future,
      skipLoadingOnRefresh: true,
      loading: () => const OrdersShimmer(),
      data: (orders) {
        final filtered = _filterOrders(orders);
        final notifier = ref.read(fetchMyOrdersProvider.notifier);
        final canLoadMore = !notifier.isLastPage();

        if (filtered.isEmpty && canLoadMore) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ref.read(fetchMyOrdersProvider.notifier).fetchNextPage();
          });
          return const OrdersShimmer();
        }

        final showFooter = filtered.isNotEmpty && canLoadMore;
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(fetchMyOrdersProvider);
            try {
              await ref.read(fetchMyOrdersProvider.future);
            } catch (_) {}
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: OrdersEmpty(
                    title: widget.scheduledOnly
                        ? 'No scheduled orders yet'.tr
                        : null,
                    message: widget.scheduledOnly
                        ? 'Your scheduled orders will appear here'.tr
                        : null,
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (showFooter && index == filtered.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: LoadingWidget(size: 24),
                          );
                        }
                        final order = filtered[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == filtered.length - 1 ? 0 : 16,
                          ),
                          child: _OrderCard(
                            order: order,
                            onRateTap: () => startOrderRatingFlow(order),
                            onReorder: () => reorderOrder(order.id),
                          ),
                        );
                      },
                      childCount: filtered.length + (showFooter ? 1 : 0),
                    ),
                  ),
                ),
                SliverGap(MediaQuery.paddingOf(context).bottom + 24),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _OrderCard extends ConsumerWidget {
  const _OrderCard({
    required this.order,
    required this.onRateTap,
    required this.onReorder,
  });

  final OrderEntity order;
  final VoidCallback onRateTap;
  final VoidCallback onReorder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(expandedOrderProvider(order.id));
    final isReordering = ref.watch(
      isLoadingProvider(OrdersActionsMixin.reorderLoadingKey(order.id)),
    );

    final (statusBg, statusText, statusLabel) = switch (order.status) {
      OrderStatus.pending ||
      OrderStatus.confirmed ||
      OrderStatus.processing ||
      OrderStatus.readyForPickup ||
      OrderStatus.outForDelivery =>
        (
          const Color(0xFFCBE3BF),
          const Color(0xFF1C622E),
          orderStatusLabel(order.status),
        ),
      OrderStatus.rejected || OrderStatus.cancelled || OrderStatus.refunded => (
          const Color(0xFFFFE0E0),
          const Color(0xFFB42318),
          orderStatusLabel(order.status),
        ),
      OrderStatus.delivered => (
          const Color(0xFFE6E6E6),
          const Color(0xFF808080),
          orderStatusLabel(order.status),
        ),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.toNamed(
          '/order-details',
          parameters: {'id': order.id},
        ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE6E6E6)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 12, right: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatOrderDateTime(context, order.createdAt),
                          style: AppFont.font16W500Black
                              .copyWith(color: const Color(0xFF111111)),
                        ),
                        const Gap(6),
                        Text(
                          'Order number'.trParams({'id': order.id}),
                          style: AppFont.font14W500Black.copyWith(
                            color: const Color(0xFF808080),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        if (order.isScheduledOrder) ...[
                          const Gap(8),
                          _ScheduledOrderBadge(
                            scheduledAt: order.scheduledDeliveryAt,
                          ),
                        ],
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            statusLabel,
                            style: AppFont.font12w500Grey2
                                .copyWith(color: statusText),
                          ),
                        ),
                        const Gap(6),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            ref
                                    .read(expandedOrderProvider(order.id).notifier)
                                    .state =
                                !ref.read(expandedOrderProvider(order.id));
                          },
                          child: Row(
                            children: [
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: const Color(0xFF3F3D56),
                              ),
                              const Gap(2),
                              Text(
                                '${order.itemsCount} ${'Products'.tr}',
                                style: AppFont.font14W500Black.copyWith(
                                  color: const Color(0xFF3F3D56),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isExpanded) ...[
                const Gap(16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < order.productItems.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: i == order.productItems.length - 1 &&
                                    order.addonItems.isEmpty
                                ? 0
                                : 10,
                          ),
                          child: _OrderProductRow(
                            item: order.productItems[i],
                            priceText:
                                _formatMoney(order.productItems[i].price),
                          ),
                        ),
                      if (order.addonItems.isNotEmpty) ...[
                        const Gap(6),
                        Text(
                          'Pharmacy addons'.tr,
                          style: AppFont.font14W500Black.copyWith(
                            color: const Color(0xFF111111),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Gap(8),
                        for (var i = 0; i < order.addonItems.length; i++)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: i == order.addonItems.length - 1 ? 0 : 8,
                            ),
                            child: _OrderAddonRow(
                              item: order.addonItems[i],
                              priceText:
                                  _formatMoney(order.addonItems[i].price),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!order.hidesOrderActions &&
                        (order.canReorder || order.canTrack))
                      _OrderActionButton(
                        canReorder: order.canReorder,
                        isLoading: isReordering,
                        onTap: () {
                          if (order.canReorder) {
                            onReorder();
                            return;
                          }
                          Get.toNamed(
                            '/track-order',
                            arguments: {'id': order.id},
                          );
                        },
                      )
                    else
                      const SizedBox.shrink(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatMoney(order.totalPrice),
                          style: AppFont.font14W500Black.copyWith(
                            color: const Color(0xFF111111),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Gap(3),
                        Text(
                          'Payment details'.tr,
                          style: AppFont.font12w500Grey2.copyWith(
                            color: const Color(0xFF111111),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (order.canRate)
                GestureDetector(
                  onTap: onRateTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEBEBEB),
                      borderRadius: BorderRadiusDirectional.only(
                        bottomStart: Radius.circular(12),
                        bottomEnd: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star,
                            color: Color(0xFFF2C71C), size: 16),
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
                )
              else if (order.hasUserRatings)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEBEBEB),
                    borderRadius: BorderRadiusDirectional.only(
                      bottomStart: Radius.circular(12),
                      bottomEnd: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star,
                              color: Color(0xFFF2C71C), size: 16),
                          const Gap(8),
                          Text(
                            'Your ratings'.tr,
                            style: AppFont.font14W500Black.copyWith(
                              color: const Color(0xFF808080),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          if (order.ratingOutOf5 > 0) ...[
                            const Gap(6),
                            Text(
                              '${order.ratingOutOf5}/5',
                              style: AppFont.font14W500Black.copyWith(
                                color: const Color(0xFF808080),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (order.ratedVendors.isNotEmpty) ...[
                        const Gap(4),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            ...order.ratedVendors.take(2).map(
                              (vendor) {
                                final rating = vendor.userRating!;
                                final name = vendor.name.isNotEmpty
                                    ? vendor.name
                                    : 'Vendor'.tr;
                                return Padding(
                                  padding: EdgeInsetsDirectional.only(top: 2, end: vendor == order.ratedVendors.last ? 0 : 8),
                                  child: Text(
                                    '$name · ${rating.ratingOutOf5}/5',
                                    style: AppFont.font12w500Grey2.copyWith(
                                      color: const Color(0xFF808080),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMoney(double value) {
    return '${value.round()} ${'EGP'.tr}';
  }

  String _formatOrderDateTime(BuildContext context, DateTime dt) {
    final locale = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    return DateFormat('d MMMM • h:mma', locale).format(dt);
  }
}

class _ScheduledOrderBadge extends StatelessWidget {
  const _ScheduledOrderBadge({this.scheduledAt});

  final DateTime? scheduledAt;

  @override
  Widget build(BuildContext context) {
    final locale = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final timeText = scheduledAt == null
        ? null
        : formatOrderScheduledDeliveryAt(scheduledAt!, locale: locale);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 14,
            color: Color(0xFF2F6FED),
          ),
          const Gap(4),
          Text(
            timeText == null
                ? 'Scheduled order'.tr
                : 'Scheduled for @time'.trParams({'time': timeText}),
            style: AppFont.font12w500Grey2.copyWith(
              color: const Color(0xFF2F6FED),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderProductRow extends StatelessWidget {
  const _OrderProductRow({
    required this.item,
    required this.priceText,
  });

  final OrderItemEntity item;
  final String priceText;

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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFont.font14W500Black.copyWith(
                  color: const Color(0xFF111111),
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (variant.isNotEmpty) ...[
                const Gap(2),
                Text(
                  variant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.font12w500Grey2.copyWith(
                    color: const Color(0xFF808080),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
              if (additions.isNotEmpty) ...[
                const Gap(2),
                Text(
                  additions,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.font12w500Grey2.copyWith(
                    color: AppColor.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
        const Gap(8),
        Text(
          priceText,
          style:
              AppFont.font12w500Grey2.copyWith(color: const Color(0xFF808080)),
        ),
      ],
    );
  }
}

class _OrderAddonRow extends StatelessWidget {
  const _OrderAddonRow({
    required this.item,
    required this.priceText,
  });

  final OrderItemEntity item;
  final String priceText;

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
                style: AppFont.font14W500Black.copyWith(
                  color: const Color(0xFF111111),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(4),
              Text(
                item.addonSubtitle(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFont.font12w500Grey2.copyWith(
                  color: const Color(0xFF999999),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
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
              style: AppFont.font12w500Grey2.copyWith(
                color: const Color(0xFF808080),
              ),
            ),
            const Gap(2),
            Text(
              priceText,
              style: AppFont.font12w500Grey2.copyWith(
                color: AppColor.guestOrange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OrderActionButton extends StatelessWidget {
  const _OrderActionButton({
    required this.canReorder,
    required this.onTap,
    this.isLoading = false,
  });

  final bool canReorder;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final label = canReorder ? 'Order again'.tr : 'Track order'.tr;

    if (!canReorder) {
      return InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 40,
          width: 110,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            gradient: AppColor.defaultPrimaryGradient,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style:
                AppFont.font14W500White.copyWith(fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 40,
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFEFEFE),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColor.primary),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const LoadingWidget(size: 18)
            : Text(
                label,
                style: AppFont.font14W500Black.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColor.primary,
                ),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
