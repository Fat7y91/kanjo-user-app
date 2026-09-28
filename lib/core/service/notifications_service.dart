import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:heraj/features/conversations/domain/entities/conversation_entity.dart';
import 'package:heraj/features/conversations/domain/entities/conversation_websocket_entity.dart';
import 'package:heraj/features/conversations/presentation/view/conversation_chat_screen.dart';
import '../../ui/ui.dart';
import 'local_data_manager.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('🔔 Background message received: ${message.messageId}');
    print('📱 Notification: ${message.notification?.title}');
    print('📦 Data: ${message.data}');
  }
}

Future setupNotification() async {
  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      print(
          '📱 Notification permission status: ${settings.authorizationStatus}');
    }

    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null && token.isNotEmpty) {
      await dataManager.setFCMToken(token);
      if (kDebugMode) {
        print('🔑 FCM Token: $token');
      }
    } else if (kDebugMode) {
      print('⚠️ FCM Token was null after permission request');
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      dataManager.setFCMToken(newToken);
      if (kDebugMode) {
        print('🔄 FCM Token refreshed: $newToken');
      }
    });

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        if (kDebugMode) {
          print('🔔 Foreground message received:');
          print('📱 Title: ${message.notification?.title}');
          print('📱 Body: ${message.notification?.body}');
          print('📦 Data: ${message.data}');
          print('📦 Message ID: ${message.messageId}');
        }

        _showNotificationSnackBar(message);
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        if (kDebugMode) {
          print('🔔 App opened from notification:');
          print('📱 Title: ${message.notification?.title}');
          print('📦 Data: ${message.data}');
        }
        _handleNotificationTap(message);
      },
    );

    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        print('🔔 App opened from terminated state via notification');
        print('📦 Notification data: ${initialMessage.data}');
      }
      await dataManager.setValue('pending_notification', initialMessage.data);
      Future.delayed(const Duration(seconds: 4), () {
        _handleInitialNotificationNavigation(initialMessage);
      });
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('❌ Error setting up notifications: $e');
      print('❌ Stack trace: $stackTrace');
    }
    FirebaseCrashlytics.instance.recordError(e, stackTrace);
  }
}

void _handleNotificationTap(RemoteMessage message) {
  try {
    final data = message.data;
    final user = dataManager.getUser();
    final token = dataManager.getToken();

    if (token != null && user != null) {
      final type = (data['type'] as String? ?? '').toLowerCase();
      final link = (data['link'] as String? ?? '').toLowerCase();
      final relatedId =
          data['relatedId'] as String? ?? data['id'] as String? ?? '';

      if (_openVendorConversationFromPayload(
        Map<String, dynamic>.from(data),
        vendorNameFallback: message.notification?.title,
      )) {
        return;
      }

      if (relatedId.isNotEmpty && (type == 'order' || link.contains('order'))) {
        Get.toNamed('/orders', arguments: {'openOrderId': relatedId});
      } else if (relatedId.isNotEmpty &&
          (type == 'product' || link.contains('product'))) {
        Get.toNamed('/product-details', arguments: {'productId': relatedId});
      } else if (type == 'chat') {
        Get.toNamed('/home');
      } else if (type == 'cart') {
        Get.toNamed('/cart');
      } else {
        Get.toNamed('/home');
      }
    } else {
      Get.toNamed('/login');
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('❌ Error handling notification tap: $e');
    }
    FirebaseCrashlytics.instance.recordError(e, stackTrace);
  }
}

/// Opens [ConversationChatScreen] for FCM / in-app payloads like:
/// `{type: vendor_conversation.message, conversation_id: 4, vendor_id: 6, ...}`
bool _openVendorConversationFromPayload(
  Map<String, dynamic> data, {
  String? vendorNameFallback,
}) {
  final type = (data['type']?.toString() ?? '').toLowerCase();
  if (type != 'vendor_conversation.message' &&
      !type.startsWith('vendor_conversation')) {
    return false;
  }

  final conversationId = _notificationInt(data['conversation_id']);
  if (conversationId == null || conversationId <= 0) return false;

  final vendorId = _notificationInt(data['vendor_id']) ?? 0;
  final vendorName = vendorNameFallback?.trim().isNotEmpty == true
      ? vendorNameFallback!.trim()
      : (data['vendor_name']?.toString() ?? '');

  final conversation = ConversationEntity(
    id: conversationId,
    vendorId: vendorId,
    vendorName: vendorName,
    vendorSlug: data['vendor_slug']?.toString() ?? '',
    userId: _notificationInt(data['user_id']) ?? 0,
    userName: data['user_name']?.toString() ?? '',
    status: 'open',
    vendorHasUnread: false,
    userHasUnread: false,
    latestMessageId: _notificationInt(data['message_id']),
    websocket: ConversationWebsocketEntity(
      channel: 'vendor-conversations.$conversationId',
      event: 'message.created',
    ),
  );

  ConversationChatScreen buildChat() =>
      ConversationChatScreen(conversation: conversation);
  if (Get.currentRoute.contains('ConversationChatScreen')) {
    Get.off(buildChat);
  } else {
    Get.to(buildChat);
  }
  return true;
}

int? _notificationInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

void _showNotificationSnackBar(RemoteMessage message) {
  if (Get.context != null) {
    try {
      UIHelper.showGlobalSnackBar(
        text: message.notification?.body,
        title: message.notification?.title,
        onTap: (j) {
          _handleNotificationTap(message);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error showing snackbar, app may not be ready yet: $e');
      }
      Future.delayed(const Duration(seconds: 2), () {
        if (Get.context != null) {
          try {
            UIHelper.showGlobalSnackBar(
              text: message.notification?.body,
              title: message.notification?.title,
              onTap: (j) {
                _handleNotificationTap(message);
              },
            );
          } catch (e2) {
            if (kDebugMode) {
              print('❌ Failed to show snackbar after retry: $e2');
            }
          }
        }
      });
    }
  } else {
    print("============================");
    if (kDebugMode) {
      print('⚠️ App not ready, queuing notification for later');
    }
    Future.delayed(const Duration(seconds: 2), () {
      print("object");
      _showNotificationSnackBar(message);
    });
  }
}

void _handleInitialNotificationNavigation(RemoteMessage message) {
  try {
    dataManager.deleteValue('pending_notification');

    final data = message.data;
    final user = dataManager.getUser();
    final token = dataManager.getToken();

    if (kDebugMode) {
      print('🔔 Handling initial notification navigation');
      print('📦 Data: $data');
    }

    if (token != null && user != null) {
      final type = (data['type'] as String? ?? '').toLowerCase();
      final link = (data['link'] as String? ?? '').toLowerCase();
      final relatedId =
          data['relatedId'] as String? ?? data['id'] as String? ?? '';

      Get.offAllNamed('/home');
      if (_openVendorConversationFromPayload(
        Map<String, dynamic>.from(data),
        vendorNameFallback: message.notification?.title,
      )) {
        return;
      }
      if (relatedId.isNotEmpty && (type == 'order' || link.contains('order'))) {
        Get.toNamed('/orders', arguments: {'openOrderId': relatedId});
      } else if (relatedId.isNotEmpty &&
          (type == 'product' || link.contains('product'))) {
        Get.toNamed('/product-details', arguments: {'productId': relatedId});
      }
    } else {
      Get.offAllNamed('/login');
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('❌ Error handling initial notification navigation: $e');
    }
    FirebaseCrashlytics.instance.recordError(e, stackTrace);
  }
}
