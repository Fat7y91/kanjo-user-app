import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:heraj/config/api_path.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/core/service/webservice/dio_helper.dart';

class FCMTokenService {
  final ApiService apiService;

  FCMTokenService(this.apiService);

  /// Returns a usable FCM token, refreshing from Firebase when local cache is empty.
  Future<String?> ensureFcmToken({bool requestPermission = true}) async {
    final cached = dataManager.getFCMToken();
    if (cached != null && cached.isNotEmpty) {
      if (kDebugMode) {
        print('🔑 FCM Token (cached): $cached');
      }
      return cached;
    }

    try {
      if (requestPermission) {
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          print('⚠️ FCM getToken() returned null/empty');
        }
        return null;
      }

      await dataManager.setFCMToken(token);
      if (kDebugMode) {
        print('🔑 FCM Token (fresh): $token');
      }
      return token;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error ensuring FCM token: $e');
        print('❌ Stack: $stackTrace');
      }
      return null;
    }
  }

  Future<bool> registerFCMToken() async {
    try {
      final token = await ensureFcmToken();
      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          print(
            '⚠️ FCM Token is not available. Make sure notification permission is granted.',
          );
        }
        return false;
      }

      await apiService.put(
        url: ApiPath.registerFCMToken,
        queryParameters: {
          'fcm-token': token,
        },
        returnDataOnly: false,
      );

      if (kDebugMode) {
        print('✅ FCM Token registered successfully: $token');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error registering FCM token: $e');
      }
      return false;
    }
  }

  Future<bool> removeFCMToken() async {
    try {
      final fcmToken = dataManager.getFCMToken();
      if (fcmToken == null || fcmToken.isEmpty) {
        if (kDebugMode) {
          print('⚠️ No FCM Token to remove');
        }
        return true;
      }

      await apiService.delete(
        url: ApiPath.removeFCMToken,
        requestBody: {
          'token': fcmToken,
        },
        returnDataOnly: false,
      );

      if (kDebugMode) {
        print('✅ FCM Token removed successfully: $fcmToken');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error removing FCM token: $e');
      }
      return true;
    }
  }
}
