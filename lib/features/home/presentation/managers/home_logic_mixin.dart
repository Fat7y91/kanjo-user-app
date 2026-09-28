import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import '../../../../core/service/location_service/location_provider.dart';
import '../../../cart/presentation/managers/fetch_cart_provider.dart';
import '../../../conversations/presentation/managers/conversations_provider.dart';
import '../../../location/presentation/managers/location_provider.dart';
import '../../../orders/presentation/manager/orders_provider.dart';
import '../../../service_chats/presentation/managers/service_chats_provider.dart';
import '../../../offers/presentation/managers/offers_provider.dart';
import '../../../vendor/presentation/managers/fetch_vendor_types_provider.dart';
import 'fetch_sliders_provider.dart';
import 'home_products_provider.dart';
import 'home_vendors_provider.dart';

mixin HomeLogicMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  late final ValueNotifier<bool> showFloatingCart;

  Future<void> onRefresh() async {
    ref.invalidate(fetchLocationDetailsProvider);
    ref.invalidate(locationAccessGrantedProvider);
    ref.invalidate(fetchDeliveryZonesProvider);
    ref.invalidate(homeVendorsProvider);
    ref.invalidate(fetchVendorTypesProvider);
    ref.invalidate(fetchCartProvider);
    ref.invalidate(fetchSlidersProvider);
    ref.invalidate(fetchOffersProvider);
    if ((dataManager.getToken() ?? '').isNotEmpty) {
      ref.invalidate(fetchConversationsProvider);
      ref.invalidate(fetchServiceConversationsProvider);
      ref.invalidate(fetchMyOrdersProvider);
    }
    ref.invalidate(homeProductsProvider);
    final activeOrder = ref.read(lastActiveOrderProvider).valueOrNull;
    if (activeOrder != null) {
      ref.invalidate(fetchOrderDetailsProvider(activeOrder.id));
    }
    await Future.wait([
      ref.read(fetchLocationDetailsProvider.future),
      ref.read(homeVendorsProvider.future),
      ref.read(fetchVendorTypesProvider.future),
      ref.read(fetchSlidersProvider.future),
      ref.read(fetchOffersProvider.future),
      ref.read(homeProductsProvider.future),
      if ((dataManager.getToken() ?? '').isNotEmpty) ...[
        ref.read(fetchCartProvider.future),
        ref.read(fetchConversationsProvider.future),
        ref.read(fetchServiceConversationsProvider.future),
        ref.read(fetchMyOrdersProvider.future),
      ],
    ].map((future) => future.then<void>((_) {}, onError: (_) {})));
  }

  bool onNotification(ScrollNotification notification) {
    return false;
  }

  bool onScrollNotification(
    ScrollNotification notification,
    ValueNotifier<bool> showFloatingCart,
  ) {
    if (dataManager.isGuest) {
      if (showFloatingCart.value) showFloatingCart.value = false;
      return onNotification(notification);
    }
    if (notification is ScrollUpdateNotification ||
        notification is ScrollEndNotification) {
      final shouldShow = notification.metrics.pixels >= 140;
      if (showFloatingCart.value != shouldShow) {
        showFloatingCart.value = shouldShow;
      }
    }
    return onNotification(notification);
  }
}
