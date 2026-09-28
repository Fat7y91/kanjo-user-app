import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/core/models/paginated_response.dart';
import 'package:heraj/features/services/domain/entities/service_order_entity.dart';
import 'package:heraj/features/services/domain/use_case/get_my_service_orders_use_case.dart';
import 'package:heraj/main.dart';

class MyServiceOrdersNotifier
    extends AutoDisposeAsyncNotifier<List<ServiceOrderEntity>> {
  int _nextPage = 1;
  int _lastPage = 1;
  bool _loadingMore = false;

  bool get isLoadingMore => _loadingMore;

  bool isLastPage() => _nextPage > _lastPage;

  @override
  Future<List<ServiceOrderEntity>> build() async {
    _nextPage = 1;
    _lastPage = 1;
    _loadingMore = false;

    final result = await getIt<GetMyServiceOrdersUseCase>().call(
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
      final result = await getIt<GetMyServiceOrdersUseCase>().call(
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
}

final fetchMyServiceOrdersProvider = AsyncNotifierProvider.autoDispose<
    MyServiceOrdersNotifier, List<ServiceOrderEntity>>(
  MyServiceOrdersNotifier.new,
);
