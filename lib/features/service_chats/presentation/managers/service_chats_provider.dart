import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/core/models/paginated_response.dart';
import 'package:heraj/core/service/socket_service/conversation_realtime_service.dart';
import 'package:heraj/core/service/socket_service/realtime_logger.dart';
import 'package:heraj/features/conversations/data/models/conversation_realtime_event_model.dart';
import 'package:heraj/features/conversations/domain/entities/conversation_message_entity.dart';
import 'package:heraj/features/conversations/domain/entities/conversation_subscription_entity.dart';
import 'package:heraj/features/conversations/domain/entities/conversation_sync_entity.dart';
import 'package:heraj/features/service_chats/data/models/service_conversations_list_model.dart';
import 'package:heraj/features/service_chats/domain/entities/service_conversation_entity.dart';
import 'package:heraj/features/service_chats/domain/use_case/fetch_service_chat_messages_use_case.dart';
import 'package:heraj/features/service_chats/domain/use_case/fetch_service_conversations_use_case.dart';
import 'package:heraj/main.dart';

class ServiceConversationsListNotifier
    extends AutoDisposeAsyncNotifier<List<ServiceConversationEntity>> {
  static const _userSubscriptionKey = 'service-conversations:user';

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
  Future<List<ServiceConversationEntity>> build() async {
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
      final result = await getIt<FetchServiceConversationsUseCase>().call(
        const FetchServiceConversationsParams(
          page: 1,
          perPage: PaginationConfig.perPage,
        ),
      );

      return result.fold((l) => throw l, (r) {
        _applyListMetadata(r, isFirstPage: true);
        _bindRealtime();
        final unread = unreadConversationIds.toSet();
        return _sortConversations([
          for (final item in r.items)
            item.copyWith(
              userHasUnread: unread.contains(item.id),
              userUnreadCount: unread.contains(item.id)
                  ? (item.userUnreadCount > 0 ? item.userUnreadCount : 1)
                  : 0,
            ),
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
      final result = await getIt<FetchServiceConversationsUseCase>().call(
        FetchServiceConversationsParams(
          page: _nextPage,
          perPage: PaginationConfig.perPage,
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

  void upsertConversation(ServiceConversationEntity conversation) {
    final current = state.value ?? const <ServiceConversationEntity>[];
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

  void applyRealtimeEvent(ChatRealtimePayload payload) {
    if (!payload.isServiceConversation) return;
    final conversation =
        ServiceConversationEntity.fromJson(payload.conversationJson);
    final messagesProvider = serviceChatMessagesProvider(conversation.id);
    final chatOpen = ref.exists(messagesProvider);
    if (chatOpen) {
      ref.read(messagesProvider.notifier).appendMessage(payload.message);
      upsertConversation(
        conversation.copyWith(userHasUnread: false, userUnreadCount: 0),
      );
      markConversationRead(conversation.id);
      return;
    }
    upsertConversation(conversation);
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
            userUnreadCount: 0,
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
      ref.read(serviceConversationsUnreadIdsProvider.notifier).state = snapshot;
    });
  }

  void _applyListMetadata(
    ServiceConversationsListModel model, {
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
      'bind service user channel="$channel" event="$event"',
    );
    if (channel.isEmpty || event.isEmpty) {
      RealtimeLogger.w(
        'service user subscription skipped — API did not return channel/event',
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
        onEvent: applyRealtimeEvent,
      ),
    );
  }
}

final fetchServiceConversationsProvider = AsyncNotifierProvider.autoDispose<
    ServiceConversationsListNotifier, List<ServiceConversationEntity>>(
  ServiceConversationsListNotifier.new,
);

final serviceConversationsUnreadIdsProvider =
    StateProvider<List<int>>((ref) => const []);

final serviceConversationsUnreadCountProvider = Provider<int>((ref) {
  return ref.watch(serviceConversationsUnreadIdsProvider).length;
});

class ServiceChatMessagesNotifier extends AutoDisposeFamilyAsyncNotifier<
    List<ConversationMessageEntity>, int> {
  int _nextOlderPage = 2;
  int _lastPage = 1;
  bool _loadingMore = false;
  ConversationSubscriptionsEntity subscriptions =
      const ConversationSubscriptionsEntity(
    user: ConversationChannelEntity(channel: '', event: ''),
  );

  bool get isLoadingMore => _loadingMore;

  /// Page 1 is newest; pages 2..last are older.
  bool get hasOlderPages => _nextOlderPage <= _lastPage;

  @override
  Future<List<ConversationMessageEntity>> build(int conversationId) async {
    _nextOlderPage = 2;
    _lastPage = 1;
    _loadingMore = false;

    final first = await getIt<FetchServiceChatMessagesUseCase>().call(
      FetchServiceChatMessagesParams(
        conversationId: conversationId,
        page: 1,
        perPage: PaginationConfig.largePerPage,
      ),
    );

    final firstPage = first.fold((l) => throw l, (r) => r);
    _lastPage =
        firstPage.pagination.lastPage < 1 ? 1 : firstPage.pagination.lastPage;
    _nextOlderPage = 2;
    subscriptions = firstPage.subscriptions;
    final conversation = firstPage.conversation;
    if (conversation != null) {
      ref
          .read(fetchServiceConversationsProvider.notifier)
          .upsertConversation(conversation);
    }
    return _sorted(firstPage.items);
  }

  Future<void> fetchOlderPage() async {
    if (_loadingMore || !hasOlderPages) return;
    _loadingMore = true;
    final page = _nextOlderPage;
    try {
      final result = await getIt<FetchServiceChatMessagesUseCase>().call(
        FetchServiceChatMessagesParams(
          conversationId: arg,
          page: page,
          perPage: PaginationConfig.largePerPage,
        ),
      );
      result.fold((l) {}, (r) {
        _lastPage =
            r.pagination.lastPage < 1 ? _lastPage : r.pagination.lastPage;
        _nextOlderPage = page + 1;
        if (r.items.isEmpty) return;
        state = AsyncData(_sorted([...r.items, ...?state.value]));
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
}

final serviceChatMessagesProvider = AsyncNotifierProvider.autoDispose
    .family<ServiceChatMessagesNotifier, List<ConversationMessageEntity>, int>(
  ServiceChatMessagesNotifier.new,
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

List<ServiceConversationEntity> _sortConversations(
  List<ServiceConversationEntity> items,
) {
  final unique = <int, ServiceConversationEntity>{};
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
