import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/orders/presentation/view/widgets/orders_empty.dart';
import 'package:heraj/features/orders/presentation/view/widgets/orders_shimmer.dart';
import 'package:heraj/features/services/domain/entities/service_order_entity.dart';
import 'package:heraj/features/services/presentation/managers/service_orders_provider.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';

class ServiceBookingsTab extends ConsumerStatefulWidget {
  const ServiceBookingsTab({super.key});

  @override
  ConsumerState<ServiceBookingsTab> createState() => _ServiceBookingsTabState();
}

class _ServiceBookingsTabState extends ConsumerState<ServiceBookingsTab> {
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
    final notifier = ref.read(fetchMyServiceOrdersProvider.notifier);
    if (notifier.isLastPage()) return;
    notifier.fetchNextPage();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(fetchMyServiceOrdersProvider);

    return bookingsAsync.customWhen(
      ref: ref,
      refreshable: fetchMyServiceOrdersProvider.future,
      skipLoadingOnRefresh: true,
      loading: () => const OrdersShimmer(),
      data: (bookings) {
        final showFooter = bookings.isNotEmpty &&
            !ref.read(fetchMyServiceOrdersProvider.notifier).isLastPage();
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(fetchMyServiceOrdersProvider);
            try {
              await ref.read(fetchMyServiceOrdersProvider.future);
            } catch (_) {}
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (bookings.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: OrdersEmpty(
                    title: 'No bookings yet'.tr,
                    message: 'Your service bookings will appear here'.tr,
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (showFooter && index == bookings.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: LoadingWidget(size: 24),
                          );
                        }
                        final booking = bookings[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == bookings.length - 1 ? 0 : 16,
                          ),
                          child: _ServiceBookingCard(booking: booking),
                        );
                      },
                      childCount: bookings.length + (showFooter ? 1 : 0),
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

class _ServiceBookingCard extends StatelessWidget {
  const _ServiceBookingCard({required this.booking});

  final ServiceOrderEntity booking;

  @override
  Widget build(BuildContext context) {
    final languageCode = Get.locale?.languageCode;
    final serviceTitle = booking.serviceName.localized(languageCode);
    final statusStyle = _statusStyle(booking.status);
    final imageUrl = booking.providerImageUrl?.trim() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.isEmpty
                    ? Container(
                        width: 52,
                        height: 52,
                        color: AppColor.primaryDark,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.handyman_outlined,
                          color: AppColor.primary,
                        ),
                      )
                    : ImageOrSvg(
                        imageUrl,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                      ),
              ),
              const Gap(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceTitle.isNotEmpty
                          ? serviceTitle
                          : 'Service booking'.tr,
                      style: AppFont.font16W500Black.copyWith(
                        color: const Color(0xFF111111),
                      ),
                    ),
                    if (booking.providerName.isNotEmpty) ...[
                      const Gap(4),
                      Text(
                        booking.providerName,
                        style: AppFont.font14W500Black.copyWith(
                          color: const Color(0xFF808080),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusStyle.$1,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  statusStyle.$3.tr,
                  style: AppFont.font12w500Grey2.copyWith(color: statusStyle.$2),
                ),
              ),
            ],
          ),
          const Gap(12),
          Text(
            'Booking number'.trParams({'id': booking.id}),
            style: AppFont.font12w500Grey2.copyWith(
              color: const Color(0xFF808080),
            ),
          ),
          if (booking.scheduledDate.isNotEmpty ||
              booking.scheduledTime.isNotEmpty) ...[
            const Gap(6),
            Text(
              _scheduledLabel(booking),
              style: AppFont.font14W500Black.copyWith(
                color: const Color(0xFF111111),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          if (booking.addressText.isNotEmpty) ...[
            const Gap(6),
            Text(
              booking.addressText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppFont.font12w500Grey2.copyWith(
                color: const Color(0xFF808080),
              ),
            ),
          ],
          const Gap(12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              '${booking.totalPrice.round()} ${'EGP'.tr}',
              style: AppFont.font14W500Black.copyWith(
                color: const Color(0xFF111111),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _scheduledLabel(ServiceOrderEntity booking) {
    final date = booking.scheduledDate;
    final time = booking.scheduledTime;
    if (date.isNotEmpty && time.isNotEmpty) {
      return '${'Scheduled for'.tr} $date • $time';
    }
    if (date.isNotEmpty) return '${'Scheduled for'.tr} $date';
    return '${'Scheduled for'.tr} $time';
  }

  (Color, Color, String) _statusStyle(ServiceOrderStatus status) {
    return switch (status) {
      ServiceOrderStatus.pending => (
          const Color(0xFFFFF3D6),
          const Color(0xFF8A6A00),
          'Pending',
        ),
      ServiceOrderStatus.confirmed => (
          const Color(0xFFD6E8FF),
          const Color(0xFF1B4F9C),
          'Confirmed',
        ),
      ServiceOrderStatus.inProgress => (
          const Color(0xFFCBE3BF),
          const Color(0xFF1C622E),
          'In progress',
        ),
      ServiceOrderStatus.completed => (
          const Color(0xFFE6E6E6),
          const Color(0xFF808080),
          'Completed',
        ),
      ServiceOrderStatus.cancelled => (
          const Color(0xFFFFE0D6),
          const Color(0xFFC92127),
          'Cancelled',
        ),
    };
  }
}
