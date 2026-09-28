import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/core/enum/language.dart';
import 'package:heraj/core/service/socket_service/conversation_realtime_service.dart';
import 'package:heraj/core/service/fcm_token_service.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/core/service/localization_service/localization_service.dart';
import 'package:heraj/core/service/notifications_service.dart';
import 'package:heraj/features/auth/domain/use_cases/login_user_use_case.dart';
import 'package:heraj/features/auth/presentation/view/login_page.dart';
import 'package:heraj/features/auth/presentation/view/widgets/logout_confirmation_bottom_sheet.dart';
import 'package:heraj/features/settings/presentation/View/widgets/delete_account_confirmation_bottom_sheet.dart';
import 'package:heraj/features/settings/presentation/manager/app_settings_provider.dart';
import 'package:heraj/features/service_chats/presentation/view/service_conversations_screen.dart';
import 'package:heraj/features/support_tickets/presentation/view/support_tickets_screen.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/ui.dart';

mixin AppSettingsActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  Future<void> toggleNotifications(bool enabled) async {
    ref.read(notificationsEnabledProvider.notifier).state = enabled;
    await dataManager.setNotificationEnabled(enabled);

    if (dataManager.getToken() == null) return;

    try {
      if (enabled) {
        await setupNotification();
        await getIt<FCMTokenService>().registerFCMToken();
      } else {
        await getIt<FCMTokenService>().removeFCMToken();
      }
    } catch (_) {}
  }

  Future<void> changeLanguage(Language language) async {
    await localeService.changeLocale(language);
    if (mounted) setState(() {});
  }

  void openSupportTickets() {
    Get.to(() => const SupportTicketsScreen());
  }

  void openServiceChats() {
    Get.to(() => const ServiceConversationsScreen());
  }

  void showLogoutConfirmation() {
    LogoutConfirmationBottomSheet.show(
      context,
      onConfirm: logout,
    );
  }

  void showDeleteAccountConfirmation() {
    DeleteAccountConfirmationBottomSheet.show(
      context,
      onConfirm: deleteAccount,
    );
  }

  Future<void> logout() async {
    if (dataManager.getToken() != null) {
      try {
        await getIt<FCMTokenService>().removeFCMToken();
      } catch (_) {}
      await getIt<ConversationRealtimeService>().disconnect();

      await getIt<LogOutUserUseCase>().call();
      await localeService.dataManager.removeLoggedUser();
    }

    Get.offAll(() => const LoginPage());
  }

  Future<void> deleteAccount() async {
    final result = await getIt<DeleteAccountUseCase>().call();
    await result.fold(
      (failure) async {
        UIHelper.showAlert(failure.message, type: DialogType.error);
      },
      (_) async {
        try {
          await getIt<FCMTokenService>().removeFCMToken();
        } catch (_) {}
        await getIt<ConversationRealtimeService>().disconnect();
        await localeService.dataManager.removeLoggedUser();
        Get.offAll(() => const LoginPage());
      },
    );
  }
}
