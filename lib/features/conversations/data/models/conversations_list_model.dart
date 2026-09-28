import '../../../../../core/models/paginated_response.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/conversation_subscription_entity.dart';
import '../../domain/entities/conversation_sync_entity.dart';

class ConversationsListModel {
  final List<ConversationEntity> items;
  final PaginationMeta pagination;
  final List<int> unreadConversationIds;
  final ConversationSubscriptionsEntity subscriptions;
  final ConversationSyncEntity sync;

  const ConversationsListModel({
    required this.items,
    required this.pagination,
    required this.unreadConversationIds,
    required this.subscriptions,
    required this.sync,
  });

  factory ConversationsListModel.fromJson(Map<String, dynamic> json) {
    final nested = json['data'];
    final Map<String, dynamic> payload;
    if (nested is Map) {
      payload = Map<String, dynamic>.from(nested);
    } else {
      payload = json;
    }

    final parsed = parsePaginatedResponse(
      payload,
      ConversationEntity.fromJson,
    );

    final unread = payload['unread_conversation_ids'];
    final unreadIds = unread is List
        ? unread
            .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
            .where((id) => id > 0)
            .toList()
        : const <int>[];

    final subscriptionsJson = payload['subscriptions'];
    final syncJson = payload['sync'];

    return ConversationsListModel(
      items: parsed.data,
      pagination: parsed.meta,
      unreadConversationIds: unreadIds,
      subscriptions: ConversationSubscriptionsEntity.fromJson(
        subscriptionsJson is Map
            ? Map<String, dynamic>.from(subscriptionsJson)
            : null,
      ),
      sync: ConversationSyncEntity.fromJson(
        syncJson is Map ? Map<String, dynamic>.from(syncJson) : null,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptions': subscriptions.toJson(),
      'sync': sync.toJson(),
      'items': items.map((e) => e.toJson()).toList(),
      'unread_conversation_ids': unreadConversationIds,
      'pagination': pagination.toJson(),
    };
  }
}
