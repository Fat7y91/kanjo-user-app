import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/core/service/socket_service/conversation_realtime_service.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/core/service/socket_service/realtime_logger.dart';
import 'package:heraj/features/home/presentation/managers/home_products_provider.dart';
import 'package:heraj/features/orders/domain/entities/order_entity.dart';
import 'package:heraj/features/orders/presentation/manager/orders_provider.dart';
import 'package:heraj/features/products/data/models/product_model.dart';
import 'package:heraj/features/products/presentation/managers/category_products_provider.dart';
import 'package:heraj/features/products/presentation/managers/product_details_provider.dart';
import 'package:heraj/features/products/presentation/managers/search_products_provider.dart';
import 'package:heraj/main.dart';

/// Binds user-app Reverb channels from MOBILE_REALTIME_CHANNELS.md:
/// - public `products` (.product.created|updated|removed)
/// - private `customer.orders.{userId}` (.order.status.updated)
class UserAppRealtimeController {
  UserAppRealtimeController(this._ref);

  final Ref _ref;

  static const productsSubscriptionKey = 'user.app.products';
  static const ordersSubscriptionKey = 'user.app.customer.orders';

  StreamSubscription<void>? _reconnectSub;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    if ((dataManager.getToken() ?? '').isEmpty) return;
    _started = true;

    final service = getIt<ConversationRealtimeService>();
    _reconnectSub ??= service.onReconnected.listen((_) {
      RealtimeLogger.i('user-app realtime reconnect — refreshing lists');
      _refreshAfterReconnect();
      unawaited(_bindAll());
    });

    await service.connectIfPossible();
    await _bindAll();
  }

  Future<void> dispose() async {
    _started = false;
    await _reconnectSub?.cancel();
    _reconnectSub = null;
    final service = getIt<ConversationRealtimeService>();
    await service.unsubscribeByKey(productsSubscriptionKey);
    await service.unsubscribeByKey(ordersSubscriptionKey);
  }

  Future<void> _bindAll() async {
    await Future.wait([
      _bindProducts(),
      _bindCustomerOrders(),
    ]);
  }

  Future<void> _bindProducts() async {
    final service = getIt<ConversationRealtimeService>();
    await service.subscribeToRawEvents(
      subscriptionKey: productsSubscriptionKey,
      channelName: 'products',
      isPrivate: false,
      eventNames: const [
        '.product.created',
        '.product.updated',
        '.product.removed',
        'product.created',
        'product.updated',
        'product.removed',
      ],
      onEvent: (eventName, data) {
        RealtimeLogger.i('products event=$eventName keys=${data.keys}');
        _handleProductEvent(eventName, data);
      },
    );
  }

  Future<void> _bindCustomerOrders() async {
    final userId = dataManager.getUser()?.id.trim() ?? '';
    if (userId.isEmpty) {
      RealtimeLogger.w('customer.orders skipped — no user id');
      return;
    }

    final service = getIt<ConversationRealtimeService>();
    await service.subscribeToRawEvents(
      subscriptionKey: ordersSubscriptionKey,
      channelName: 'customer.orders.$userId',
      isPrivate: true,
      eventNames: const [
        '.order.status.updated',
        'order.status.updated',
      ],
      onEvent: (eventName, data) {
        RealtimeLogger.i('customer.orders event=$eventName keys=${data.keys}');
        _handleOrderStatusEvent(data);
      },
    );
  }

  void _handleProductEvent(String eventName, Map<String, dynamic> data) {
    final action = (data['action']?.toString() ?? '').toLowerCase();
    final productId = _asInt(data['product_id'] ?? data['id']);
    final productRaw = data['product'];
    final isRemoved = eventName.toLowerCase().contains('removed') ||
        action == 'removed' ||
        action == 'deleted' ||
        productRaw == null;

    ProductModel? product;
    if (productRaw is Map) {
      try {
        product = ProductModel.fromJson(Map<String, dynamic>.from(productRaw));
      } catch (error, stack) {
        RealtimeLogger.e(
          'failed to parse product payload id=$productId',
          error: error,
          stackTrace: stack,
        );
      }
    }

    if (isRemoved) {
      final id = productId ?? product?.id ?? 0;
      if (id > 0) {
        _removeProductEverywhere(id);
      } else {
        _invalidateProductLists();
      }
      return;
    }

    if (product != null) {
      _upsertProductEverywhere(product);
      return;
    }

    _invalidateProductLists();
    if (productId != null && productId > 0) {
      _ref.invalidate(productDetailsProvider(productId));
    }
  }

  void _handleOrderStatusEvent(Map<String, dynamic> data) {
    final orderId = data['order_id']?.toString() ??
        (data['order'] is Map
            ? (data['order'] as Map)['id']?.toString()
            : null) ??
        '';
    final statusRaw = data['status']?.toString();
    final orderRaw = data['order'];

    if (orderRaw is Map) {
      try {
        final order =
            OrderEntity.fromJson(Map<String, dynamic>.from(orderRaw));
        if (_ref.exists(fetchMyOrdersProvider)) {
          _ref.read(fetchMyOrdersProvider.notifier).upsertOrder(order);
        }
      } catch (error, stack) {
        RealtimeLogger.e(
          'failed to parse order payload id=$orderId',
          error: error,
          stackTrace: stack,
        );
        if (orderId.isNotEmpty && statusRaw != null) {
          _applyOrderStatus(orderId, statusRaw);
        }
      }
    } else if (orderId.isNotEmpty && statusRaw != null) {
      _applyOrderStatus(orderId, statusRaw);
    }

    if (orderId.isNotEmpty) {
      _ref.invalidate(fetchOrderDetailsProvider(orderId));
    }
  }

  void _applyOrderStatus(String orderId, String statusRaw) {
    if (!_ref.exists(fetchMyOrdersProvider)) return;
    _ref.read(fetchMyOrdersProvider.notifier).applyStatusUpdate(
          orderId: orderId,
          status: orderStatusFromApi(statusRaw),
        );
  }

  void _upsertProductEverywhere(ProductModel product) {
    if (_ref.exists(homeProductsProvider)) {
      _ref.read(homeProductsProvider.notifier).upsertProduct(product);
    }
    _ref.invalidate(fetchCategoryProductsProvider);
    _ref.invalidate(searchProductsProvider);
    _ref.invalidate(productDetailsProvider(product.id));
  }

  void _removeProductEverywhere(int productId) {
    if (_ref.exists(homeProductsProvider)) {
      _ref.read(homeProductsProvider.notifier).removeProduct(productId);
    }
    _ref.invalidate(fetchCategoryProductsProvider);
    _ref.invalidate(searchProductsProvider);
    _ref.invalidate(productDetailsProvider(productId));
  }

  void _invalidateProductLists() {
    _ref.invalidate(homeProductsProvider);
    _ref.invalidate(fetchCategoryProductsProvider);
    _ref.invalidate(searchProductsProvider);
  }

  void _refreshAfterReconnect() {
    _ref.invalidate(homeProductsProvider);
    _ref.invalidate(fetchCategoryProductsProvider);
    _ref.invalidate(searchProductsProvider);
    if (_ref.exists(fetchMyOrdersProvider)) {
      _ref.invalidate(fetchMyOrdersProvider);
    }
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}

/// Watch from [RootView] (or any logged-in shell) to keep user channels alive.
final userAppRealtimeProvider = Provider.autoDispose<void>((ref) {
  final controller = UserAppRealtimeController(ref);
  unawaited(controller.start());
  ref.onDispose(() {
    unawaited(controller.dispose());
  });
});
