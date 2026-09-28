import 'package:heraj/core/models/paginated_response.dart';
import 'package:heraj/features/conversations/domain/entities/conversation_message_entity.dart';
import 'package:heraj/features/conversations/domain/entities/conversation_subscription_entity.dart';
import 'package:heraj/features/conversations/domain/entities/conversation_sync_entity.dart';
import 'package:heraj/features/service_chats/domain/entities/service_conversation_entity.dart';

class ServiceChatMessagesModel {
  final List<ConversationMessageEntity> items;
  final PaginationMeta pagination;
  final ServiceConversationEntity? conversation;
  final ConversationSubscriptionsEntity subscriptions;
  final ConversationSyncEntity sync;

  const ServiceChatMessagesModel({
    required this.items,
    required this.pagination,
    this.conversation,
    required this.subscriptions,
    required this.sync,
  });

  factory ServiceChatMessagesModel.fromJson(Map<String, dynamic> json) {
    final nested = json['data'];
    final Map<String, dynamic> payload;
    if (nested is Map) {
      payload = Map<String, dynamic>.from(nested);
    } else {
      payload = json;
    }

    final parsed = parsePaginatedResponse(
      payload,
      ConversationMessageEntity.fromJson,
    );

    final conversationJson = payload['conversation'];
    final subscriptionsJson = payload['subscriptions'];
    final syncJson = payload['sync'];

    return ServiceChatMessagesModel(
      items: parsed.data,
      pagination: parsed.meta,
      conversation: conversationJson is Map
          ? ServiceConversationEntity.fromJson(
              Map<String, dynamic>.from(conversationJson),
            )
          : null,
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
      if (conversation != null) 'conversation': conversation!.toJson(),
      'items': items.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}
