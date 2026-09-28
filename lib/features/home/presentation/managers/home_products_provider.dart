import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/core/models/paginated_response.dart';
import 'package:heraj/features/products/data/models/product_model.dart';
import 'package:heraj/features/products/domain/use_case/fetch_products_params.dart';
import 'package:heraj/features/products/domain/use_case/fetch_products_use_case.dart';
import 'package:heraj/main.dart';

class HomeProductsNotifier extends AutoDisposeAsyncNotifier<List<ProductModel>> {
  int _nextPage = 1;
  int _lastPage = 1;
  bool _loadingMore = false;

  bool get isLoadingMore => _loadingMore;

  bool isLastPage() => _nextPage > _lastPage;

  static const _params = FetchProductsParams(vendorId: 0);

  @override
  Future<List<ProductModel>> build() async {
    _nextPage = 1;
    _lastPage = 1;
    _loadingMore = false;

    final result = await getIt<FetchProductsUseCase>().call(
      _params.copyWith(page: 1, perPage: PaginationConfig.perPage),
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
      final result = await getIt<FetchProductsUseCase>().call(
        _params.copyWith(page: _nextPage, perPage: PaginationConfig.perPage),
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

  void upsertProduct(ProductModel product) {
    final current = state.value;
    if (current == null) {
      state = AsyncData([product]);
      return;
    }
    final index = current.indexWhere((e) => e.id == product.id);
    if (index < 0) {
      state = AsyncData([product, ...current]);
      return;
    }
    final next = [...current];
    next[index] = product;
    state = AsyncData(next);
  }

  void removeProduct(int productId) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.where((e) => e.id != productId).toList(),
    );
  }
}

final homeProductsProvider =
    AsyncNotifierProvider.autoDispose<HomeProductsNotifier, List<ProductModel>>(
  HomeProductsNotifier.new,
);
