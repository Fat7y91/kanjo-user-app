import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../main.dart';
import '../../domain/entities/order_details_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/use_cases/get_order_details_use_case.dart';
import '../../domain/use_cases/get_my_orders_use_case.dart';

class MyOrdersNotifier extends AutoDisposeAsyncNotifier<List<OrderEntity>> {
  int _nextPage = 1;
  int _lastPage = 1;
  bool _loadingMore = false;

  bool get isLoadingMore => _loadingMore;

  bool isLastPage() => _nextPage > _lastPage;

  @override
  Future<List<OrderEntity>> build() async {
    _nextPage = 1;
    _lastPage = 1;
    _loadingMore = false;

    final result = await getIt<GetMyOrdersUseCase>().call(
      page: 1,
      perPage: PaginationConfig.perPage,
    );
    return result.fold((l) => throw l, (r) {
      _lastPage = r.meta.lastPage;
      _nextPage = 2;
      return r.data;
    });
  }

  Future<void> fetchNextPage() async {
    if (_loadingMore || isLastPage()) return;
    _loadingMore = true;
    try {
      final result = await getIt<GetMyOrdersUseCase>().call(
        page: _nextPage,
        perPage: PaginationConfig.perPage,
      );
      result.fold((l) {}, (r) {
        _lastPage = r.meta.lastPage;
        if (r.data.isEmpty) {
          _lastPage = _nextPage - 1;
          return;
        }
        _nextPage++;
        state = AsyncData([...?state.value, ...r.data]);
      });
    } finally {
      _loadingMore = false;
    }
  }

  void upsertOrder(OrderEntity order) {
    final current = state.value;
    if (current == null) {
      state = AsyncData([order]);
      return;
    }
    final index = current.indexWhere((e) => e.id == order.id);
    if (index < 0) {
      state = AsyncData([order, ...current]);
      return;
    }
    final next = [...current];
    next[index] = order;
    state = AsyncData(next);
  }

  void applyStatusUpdate({
    required String orderId,
    required OrderStatus status,
  }) {
    final current = state.value;
    if (current == null) return;
    final index = current.indexWhere((e) => e.id == orderId);
    if (index < 0) {
      ref.invalidateSelf();
      return;
    }
    final next = [...current];
    next[index] = next[index].copyWith(status: status);
    state = AsyncData(next);
  }
}

final fetchMyOrdersProvider =
    AsyncNotifierProvider.autoDispose<MyOrdersNotifier, List<OrderEntity>>(
  MyOrdersNotifier.new,
);

/// Latest in-progress product order from the first page of my orders.
/// Returns `null` when logged out or when there is no active order.
final lastActiveOrderProvider =
    Provider.autoDispose<AsyncValue<OrderEntity?>>((ref) {
  final token = dataManager.getToken();
  if (token == null || token.isEmpty) {
    return const AsyncData(null);
  }
  return ref.watch(fetchMyOrdersProvider).whenData((orders) {
    for (final order in orders) {
      if (order.isActive) return order;
    }
    return null;
  });
});

final expandedOrderProvider =
    StateProvider.autoDispose.family<bool, String>((ref, id) => false);

final fetchOrderDetailsProvider = FutureProvider.autoDispose
    .family<OrderDetailsEntity, String>((ref, orderId) async {
  final result = await getIt<GetOrderDetailsUseCase>().call(orderId);
  return result.fold((l) => throw l, (r) => r);
});
