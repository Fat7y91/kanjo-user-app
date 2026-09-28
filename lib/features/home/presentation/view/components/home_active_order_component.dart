import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/features/orders/domain/entities/order_entity.dart';
import 'package:heraj/features/orders/presentation/manager/orders_provider.dart';
import 'package:heraj/features/orders/presentation/view/widgets/order_eta_card.dart';

class HomeActiveOrderComponent extends ConsumerWidget {
  const HomeActiveOrderComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(lastActiveOrderProvider);

    return activeAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (order) {
        if (order == null) return const SizedBox.shrink();
        final detailsAsync = ref.watch(fetchOrderDetailsProvider(order.id));
        return detailsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (details) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: OrderEtaCard(
                entity: details,
                isHome: true,
                showTrack: !details.hidesOrderActions &&
                    details.status != OrderStatus.delivered,
                onTrack: () => Get.toNamed(
                  '/order-details',
                  parameters: {'id': details.orderId},
                ),
                onPlay: () => Get.toNamed('/games'),
              ),
            );
          },
        );
      },
    );
  }
}
