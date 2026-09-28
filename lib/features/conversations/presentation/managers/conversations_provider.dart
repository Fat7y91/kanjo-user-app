import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/core/models/paginated_response.dart';
import 'package:heraj/core/service/socket_service/conversation_realtime_service.dart';
import 'package:heraj/core/service/socket_service/realtime_logger.dart';
import 'package:heraj/features/conversations/data/models/conversation_realtime_event_model.dart';
import 'package:heraj/features/conversations/data/models/conversations_list_model.dart';
import 'package:heraj/features/conversations/domain/entities/conversation_entity.dart';
import 'package:heraj/features/conversations/domain/entities/conversation_message_entity.dart';
import 'package:heraj/features/conversations/domain/entities/conversation_subscription_entity.dart';
import 'package:heraj/features/conversations/domain/entities/conversation_sync_entity.dart';
import 'package:heraj/features/conversations/domain/use_case/fetch_conversation_messages_use_case.dart';
import 'package:heraj/features/conversations/domain/use_case/fetch_conversations_use_case.dart';
import 'package:heraj/main.dart';

class ConversationsListNotifier
    extends AutoDisposeAsyncNotifier<List<ConversationEntity>> {
  static const _userSubscriptionKey = 'conversations:user';

  int _nextPage = 1;
  int _lastPage = 1;
  bool _loadingMore = false;
  bool _disposed = false;
  List<int> unreadConversationIds = const [];
  ConversationSubscriptionsEntity subscriptions =
      const ConversationSubscriptionsEntity(
        user: ConversationChannelEntity(channel: '', event: ''),
      );
  ConversationSyncEntity sync = const ConversationSyncEntity(
    strategy: '',
    supportsIncrementalMessages: false,
  );
  StreamSubscription<void>? _reconnectSub;

  bool get isLoadingMore => _loadingMore;

  bool isLastPage() => _nextPage > _lastPage;

  @override
  Future<List<ConversationEntity>> build() async {
    ref.keepAlive();
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _reconnectSub?.cancel();
      unawaited(
        getIt<ConversationRealtimeService>().unsubscribeByKey(
          _userSubscriptionKey,
        ),
      );
    });

    _nextPage = 1;
    _lastPage = 1;
    _loadingMore = true;
    _setUnreadIds(const []);

    try {
      final result = await getIt<FetchConversationsUseCase>().call(
        const FetchConversationsParams(
          page: 1,
          perPage: PaginationConfig.largePerPage,
        ),
      );

      return result.fold((l) => throw l, (r) {
        _applyListMetadata(r, isFirstPage: true);
        _bindRealtime();
        final unread = unreadConversationIds.toSet();
        return _sortConversations([
          for (final item in r.items)
            item.copyWith(userHasUnread: unread.contains(item.id)),
        ]);
      });
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> fetchNextPage() async {
    if (_loadingMore || isLastPage() || _nextPage <= 1) return;
    _loadingMore = true;
    try {
      final result = await getIt<FetchConversationsUseCase>().call(
        FetchConversationsParams(
          page: _nextPage,
          perPage: PaginationConfig.largePerPage,
        ),
      );
      result.fold((l) {}, (r) {
        _applyListMetadata(r);
        if (r.items.isEmpty) {
          _lastPage = _nextPage - 1;
          return;
        }
        _nextPage++;
        state = AsyncData(
          _sortConversations([...?state.value, ...r.items]),
        );
      });
    } finally {
      _loadingMore = false;
    }
  }

  void upsertConversation(ConversationEntity conversation) {
    final current = state.value ?? const <ConversationEntity>[];
    final merged = [...current];
    final index = merged.indexWhere((item) => item.id == conversation.id);
    if (index == -1) {
      merged.add(conversation);
    } else {
      merged[index] = conversation;
    }
    _setUnreadIds(
      conversation.userHasUnread
          ? {...unreadConversationIds, conversation.id}
          : unreadConversationIds.where((id) => id != conversation.id),
    );
    state = AsyncData(_sortConversations(merged));
  }

  void applyRealtimeEvent(ConversationRealtimeEventModel event) {
    upsertConversation(event.conversation);
  }

  void markConversationRead(int conversationId) {
    _setUnreadIds(
      unreadConversationIds.where((id) => id != conversationId),
    );
    final current = state.value;
    if (current == null) {
      return;
    }
    state = AsyncData([
      for (final item in current)
        if (item.id == conversationId)
          item.copyWith(
            userHasUnread: false,
            userLastReadMessageId: item.latestMessageId,
          )
        else
          item,
    ]);
  }

  void _setUnreadIds(Iterable<int> ids) {
    unreadConversationIds = ids.where((id) => id > 0).toSet().toList();
    final snapshot = List<int>.from(unreadConversationIds);
    Future.microtask(() {
      if (_disposed) return;
      ref.read(conversationsUnreadIdsProvider.notifier).state = snapshot;
    });
  }

  void _applyListMetadata(
    ConversationsListModel model, {
    bool isFirstPage = false,
  }) {
    _setUnreadIds(model.unreadConversationIds);
    subscriptions = model.subscriptions;
    sync = model.sync;
    _lastPage = model.pagination.lastPage;
    if (isFirstPage) {
      _nextPage = 2;
    }
  }

  void _bindRealtime() {
    final channel = subscriptions.user.channel.trim();
    final event = subscriptions.user.event.trim();
    RealtimeLogger.i(
      'bind user channel="$channel" event="$event"',
    );
    if (channel.isEmpty || event.isEmpty) {
      RealtimeLogger.w(
        'user subscription skipped — API did not return channel/event',
      );
      return;
    }

    final service = getIt<ConversationRealtimeService>();
    _reconnectSub ??= service.onReconnected.listen((_) {
      ref.invalidateSelf();
    });
    unawaited(
      service.subscribeToChannel(
        subscriptionKey: _userSubscriptionKey,
        channelName: channel,
        eventName: event,
        isPrivate: true,
        onEvent: (payload) {
          final event = payload.asVendorEvent();
          if (event == null) return;
          applyRealtimeEvent(event);
        },
      ),
    );
  }
}

final fetchConversationsProvider = AsyncNotifierProvider.autoDispose<
    ConversationsListNotifier, List<ConversationEntity>>(
  ConversationsListNotifier.new,
);

/// Source of truth for Chat tab badge: API `unread_conversation_ids`.
final conversationsUnreadIdsProvider =
    StateProvider<List<int>>((ref) => const []);

final conversationsUnreadCountProvider = Provider<int>((ref) {
  return ref.watch(conversationsUnreadIdsProvider).length;
});

class ConversationMessagesNotifier extends AutoDisposeFamilyAsyncNotifier<
    List<ConversationMessageEntity>, int> {
  int _nextOlderPage = 2;
  int _lastPage = 1;
  bool _loadingMore = false;

  bool get isLoadingMore => _loadingMore;

  /// Page 1 is newest; pages 2..last are older.
  bool get hasOlderPages => _nextOlderPage <= _lastPage;

  @override
  Future<List<ConversationMessageEntity>> build(int conversationId) async {
    _nextOlderPage = 2;
    _lastPage = 1;
    _loadingMore = false;

    final first = await getIt<FetchConversationMessagesUseCase>().call(
      FetchConversationMessagesParams(
        conversationId: conversationId,
        page: 1,
        perPage: PaginationConfig.largePerPage,
      ),
    );

    final firstPage = first.fold((l) => throw l, (r) => r);
    _lastPage = firstPage.meta.lastPage < 1 ? 1 : firstPage.meta.lastPage;
    _nextOlderPage = 2;
    return _sorted(firstPage.data);
  }

  Future<void> fetchOlderPage() async {
    if (_loadingMore || !hasOlderPages) return;
    _loadingMore = true;
    final page = _nextOlderPage;
    try {
      final result = await getIt<FetchConversationMessagesUseCase>().call(
        FetchConversationMessagesParams(
          conversationId: arg,
          page: page,
          perPage: PaginationConfig.largePerPage,
        ),
      );
      result.fold((l) {}, (r) {
        _lastPage = r.meta.lastPage < 1 ? _lastPage : r.meta.lastPage;
        _nextOlderPage = page + 1;
        if (r.data.isEmpty) return;
        state = AsyncData(_sorted([...r.data, ...?state.value]));
      });
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> fetchNextPage() => fetchOlderPage();

  void appendMessage(ConversationMessageEntity message) {
    final current = state.value ?? const <ConversationMessageEntity>[];
    if (current.any((item) => item.id == message.id && message.id > 0)) {
      return;
    }
    state = AsyncData(_sorted([...current, message]));
  }

  void replaceMessage(ConversationMessageEntity message) {
    final current = state.value ?? const <ConversationMessageEntity>[];
    state = AsyncData(_sorted([
      for (final item in current)
        if (item.id == message.id) message else item,
    ]));
  }
}

final conversationMessagesProvider = AsyncNotifierProvider.autoDispose
    .family<ConversationMessagesNotifier, List<ConversationMessageEntity>, int>(
  ConversationMessagesNotifier.new,
);

List<ConversationMessageEntity> _sorted(
  List<ConversationMessageEntity> messages,
) {
  final unique = <int, ConversationMessageEntity>{};
  for (final message in messages) {
    unique[message.id] = message;
  }
  final list = unique.values.toList()
    ..sort((a, b) {
      final aDate = DateTime.tryParse(a.createdAt ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(a.id);
      final bDate = DateTime.tryParse(b.createdAt ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(b.id);
      return aDate.compareTo(bDate);
    });
  return list;
}

List<ConversationEntity> _sortConversations(List<ConversationEntity> items) {
  final unique = <int, ConversationEntity>{};
  for (final item in items) {
    unique[item.id] = item;
  }
  final list = unique.values.toList()
    ..sort((a, b) {
      final aDate = DateTime.tryParse(a.lastMessageAt ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(a.latestMessageId ?? a.id);
      final bDate = DateTime.tryParse(b.lastMessageAt ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(b.latestMessageId ?? b.id);
      return bDate.compareTo(aDate);
    });
  return list;
}
