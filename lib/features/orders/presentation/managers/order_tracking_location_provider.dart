import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/core/service/socket_service/conversation_realtime_service.dart';
import 'package:heraj/core/service/socket_service/realtime_logger.dart';
import 'package:heraj/features/orders/domain/entities/delivery_partner_live_update.dart';
import 'package:heraj/features/orders/domain/entities/delivery_tracking_entity.dart';
import 'package:heraj/features/orders/presentation/manager/orders_provider.dart';
import 'package:heraj/main.dart';

/// Live delivery-partner updates for a single order.
///
/// Channel + event come from order API `delivery_tracking`:
/// e.g. `private-customer.orders.149.tracking` + `delivery.partner.location.updated`
///
/// Socket payload example:
/// `{ partner_id, display_name, latitude, longitude, zone_id,
///    availability_status, updated_at, active_order_id, ... }`
class OrderTrackingLocationNotifier extends AutoDisposeFamilyAsyncNotifier<
    DeliveryPartnerLiveUpdate?, String> {
  static String subscriptionKey(String orderId) =>
      'order.tracking.location.$orderId';

  StreamSubscription<void>? _reconnectSub;
  DeliveryTrackingEntity? _tracking;

  @override
  Future<DeliveryPartnerLiveUpdate?> build(String orderId) async {
    ref.onDispose(() {
      unawaited(_reconnectSub?.cancel());
      unawaited(
        getIt<ConversationRealtimeService>().unsubscribeByKey(
          subscriptionKey(orderId),
        ),
      );
    });

    final details = await ref.watch(fetchOrderDetailsProvider(orderId).future);
    _tracking = details.deliveryTracking;
    final initial = DeliveryPartnerLiveUpdate.fromGeoPoint(
          details.driverLocation,
        ) ??
        DeliveryPartnerLiveUpdate.fromGeoPoint(details.pickupLocation) ??
        DeliveryPartnerLiveUpdate.fromGeoPoint(details.destinationLocation);

    final service = getIt<ConversationRealtimeService>();
    _reconnectSub ??= service.onReconnected.listen((_) {
      unawaited(_subscribe(orderId));
    });
    await _subscribe(orderId);

    return initial;
  }

  Future<void> _subscribe(String orderId) async {
    final tracking = _tracking;
    if (tracking == null || !tracking.isValid) {
      RealtimeLogger.w(
        'order tracking skipped — missing delivery_tracking '
        'orderId=$orderId',
      );
      return;
    }

    final event = tracking.event;
    final dotted = event.startsWith('.') ? event : '.$event';
    final undotted = event.startsWith('.') ? event.substring(1) : event;

    final service = getIt<ConversationRealtimeService>();
    await service.connectIfPossible();
    await service.subscribeToRawEvents(
      subscriptionKey: subscriptionKey(orderId),
      channelName: tracking.channel,
      isPrivate: true,
      eventNames: [dotted, undotted],
      onEvent: (eventName, data) {
        final update = DeliveryPartnerLiveUpdate.tryParse(
          data,
          expectedOrderId: orderId,
        );
        RealtimeLogger.i(
          'order tracking event=$eventName orderId=$orderId '
          'channel=${tracking.channel} '
          'parsed=${update?.toJson() ?? 'null'} raw=$data',
        );
        if (update == null) return;
        state = AsyncData(update);
      },
    );
  }
}

final orderTrackingLocationProvider = AsyncNotifierProvider.autoDispose
    .family<OrderTrackingLocationNotifier, DeliveryPartnerLiveUpdate?, String>(
  OrderTrackingLocationNotifier.new,
);
