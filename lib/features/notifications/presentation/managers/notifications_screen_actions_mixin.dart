import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/features/conversations/domain/entities/conversation_entity.dart';
import 'package:heraj/features/conversations/domain/entities/conversation_websocket_entity.dart';
import 'package:heraj/features/conversations/presentation/view/conversation_chat_screen.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/ui.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/use_case/fetch_seen_use_case.dart';
import '../../domain/use_case/mark_all_as_read_use_case.dart';
import 'fetch_notificatons_provider.dart';

mixin NotificationsScreenActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  Future<void> markAllNotificationsAsRead() async {
    final result = await getIt<MarkAllAsReadUseCase>().call();
    result.fold(
      (failure) {
        if (!mounted) return;
        UIHelper.showAlert(failure.message, type: DialogType.error);
      },
      (_) {
        if (!mounted) return;
        ref.read(fetchNotificationsProvider.notifier).markAllLocallyRead();
        ref.invalidate(unreadNotificationCountProvider);
      },
    );
  }

  Future<void> onNotificationTap(NotificationEntity notification) async {
    if (!notification.isRead) {
      await _markNotificationRead(notification.id);
    }
    _navigateFromNotification(notification);
  }

  Future<void> _markNotificationRead(String id) async {
    final result = await getIt<SeenNotificationUseCase>().call(id);
    result.fold(
      (failure) {
        if (!mounted) return;
        UIHelper.showAlert(failure.message, type: DialogType.error);
      },
      (_) {
        if (!mounted) return;
        ref.read(fetchNotificationsProvider.notifier).markLocallyRead(id);
        ref.invalidate(unreadNotificationCountProvider);
      },
    );
  }

  void _navigateFromNotification(NotificationEntity entity) {
    final type = entity.type.toLowerCase();
    final data = entity.data;

    if (type == 'vendor_conversation.message' ||
        type.startsWith('vendor_conversation')) {
      final conversationId = _asInt(data['conversation_id']) ??
          int.tryParse(entity.relatedId);
      if (conversationId != null && conversationId > 0) {
        final vendorId = _asInt(data['vendor_id']) ?? 0;
        Get.to(
          () => ConversationChatScreen(
            conversation: ConversationEntity(
              id: conversationId,
              vendorId: vendorId,
              vendorName: entity.title,
              vendorSlug: data['vendor_slug']?.toString() ?? '',
              userId: _asInt(data['user_id']) ?? 0,
              userName: data['user_name']?.toString() ?? '',
              status: 'open',
              vendorHasUnread: false,
              userHasUnread: false,
              latestMessageId: _asInt(data['message_id']),
              websocket: ConversationWebsocketEntity(
                channel: 'vendor-conversations.$conversationId',
                event: 'message.created',
              ),
            ),
          ),
        );
        return;
      }
    }

    if (type.startsWith('order.')) {
      final orderId =
          data['order_id']?.toString() ?? entity.relatedId;
      if (orderId.isEmpty) {
        Get.toNamed('/orders');
        return;
      }
      Get.toNamed('/order-details', arguments: {'id': orderId});
      return;
    }

    if (type.startsWith('service_order.')) {
      Get.toNamed('/orders', arguments: {'tab': 2});
      return;
    }

    if (entity.relatedId.isNotEmpty) {
      Get.toNamed('/order-details', arguments: {'id': entity.relatedId});
    }
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
