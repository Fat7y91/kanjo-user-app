import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import '../../../../../core/models/paginated_response.dart';
import '../../../../../main.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/use_case/fetch_notifications_use_case.dart';
import '../../domain/use_case/get_unread_count_use_case.dart';
import 'notifications_filter.dart';

class NotificationsListNotifier
    extends AutoDisposeAsyncNotifier<List<NotificationEntity>> {
  int _nextPage = 1;
  int _lastPage = 1;
  bool _loadingMore = false;
  int? _unreadFromMeta;

  bool get isLoadingMore => _loadingMore;

  int? get unreadFromMeta => _unreadFromMeta;

  bool isLastPage() => _nextPage > _lastPage;

  @override
  Future<List<NotificationEntity>> build() async {
    _nextPage = 1;
    _lastPage = 1;
    _loadingMore = false;
    _unreadFromMeta = null;

    final result = await getIt<FetchNotificationUseCase>().call({
      'page': 1,
      'per_page': PaginationConfig.perPage,
    });

    return result.fold((l) => throw l, (r) {
      _lastPage = r.meta.lastPage;
      _nextPage = 2;
      _unreadFromMeta = r.meta.unreadCount;
      return r.data;
    });
  }

  Future<void> fetchNextPage() async {
    if (_loadingMore || isLastPage()) return;
    _loadingMore = true;
    try {
      final result = await getIt<FetchNotificationUseCase>().call({
        'page': _nextPage,
        'per_page': PaginationConfig.perPage,
      });
      result.fold((l) {}, (r) {
        _lastPage = r.meta.lastPage;
        if (r.meta.unreadCount != null) {
          _unreadFromMeta = r.meta.unreadCount;
        }
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

  void markLocallyRead(String id) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([
      for (final n in current)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ]);
  }

  void markAllLocallyRead() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([
      for (final n in current) n.copyWith(isRead: true),
    ]);
  }
}

final fetchNotificationsProvider = AsyncNotifierProvider.autoDispose<
    NotificationsListNotifier, List<NotificationEntity>>(
  NotificationsListNotifier.new,
);

final filteredNotificationsProvider =
    Provider.autoDispose<AsyncValue<List<NotificationEntity>>>((ref) {
  final listAsync = ref.watch(fetchNotificationsProvider);
  final status = ref.watch(notificationsProvider)['status'] as int?;

  return listAsync.when(
    data: (list) {
      if (status == null) return AsyncData(list);
      if (status == 1) {
        return AsyncData(list.where((e) => e.isRead).toList());
      }
      return AsyncData(list.where((e) => !e.isRead).toList());
    },
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncError(e, st),
  );
});

final unreadNotificationCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  if ((dataManager.getToken() ?? '').isEmpty) return 0;
  final count = await getIt<GetUnreadCountUseCase>().call();
  return count.fold((l) => throw l, (r) => r);
});
