import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/auth_service.dart';
import 'package:heraj/core/service/socket_service/conversation_realtime_service.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/core/service/remote_config_service.dart';
import 'package:heraj/features/auth/presentation/view/login_page.dart';
import 'package:heraj/features/onboarding/view/onboard_screen.dart';
import 'package:heraj/features/root/view/root_view.dart';
import 'package:heraj/features/splash/presentation/managers/splash_provider.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/custom_outlined_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../config/app_font.dart';
import 'package:heraj/core/service/deep_linking_service/deep_linking_service.dart';
import 'package:heraj/features/share/domain/entities/share_link_resolve_entity.dart';
import 'package:heraj/features/share/presentation/managers/share_link_navigator.dart';

mixin SplashNavigationMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  Future<SplashNavigate> resolveAuthNavigation() async {
    try {
      await ref.read(fetchUserProvider.future);
    } catch (_) {
      // Profile fetch failed; fall through to token-based routing.
    }

    final res = ref.read(splashNavigateProvider);
    if (res == SplashNavigate.home) {
      await getIt<ConversationRealtimeService>().connectIfPossible();
    }
    if (res == SplashNavigate.home &&
        !dataManager.isGuest &&
        dataManager.getFingerprintEnabled() == true) {
      return SplashNavigate.login;
    }
    return res;
  }

  Future<void> finishSplashNavigation(SplashNavigate route) async {
    final showOptional = ref.read(showOptionalUpdateDialogProvider);
    if (showOptional) {
      await showOptionalUpdateDialog(route);
      return;
    }
    navigateAfterSplash(route);
  }

  void navigateAfterSplash(SplashNavigate route) {
    if (route == SplashNavigate.forceUpdate ||
        route == SplashNavigate.proceed) {
      return;
    }

    final shareTarget = getIt<DeepLinkService>().resolvedTarget;
    switch (route) {
      case SplashNavigate.home:
        Get.offAll(() => const RootView());
        break;
      case SplashNavigate.boarding:
        Get.offAll(() => const OnboardScreen());
        break;
      case SplashNavigate.login:
        Get.offAll(() => const LoginPage());
        break;
      case SplashNavigate.forceUpdate:
      case SplashNavigate.proceed:
        break;
    }

    if (shareTarget != null) {
      _openPendingShareTarget(shareTarget);
    } else {
      getIt<DeepLinkService>().markAppReady();
    }
  }

  void _openPendingShareTarget(ShareLinkResolveEntity? shareTarget) {
    if (shareTarget == null) return;
    getIt<DeepLinkService>().markAppReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShareLinkNavigator.navigate(shareTarget);
      getIt<DeepLinkService>().clear();
    });
  }

  Future<void> showOptionalUpdateDialog(SplashNavigate route) async {
    final storeLink = getIt<RemoteConfigService>().storeLink;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Update available'.tr, style: AppFont.font16W600Black),
        content: Text(
          'Update available message'.tr,
          style: AppFont.font14W500Black,
        ),
        actions: [
          CustomOutlinedButton(
            text: 'Later'.tr,
            width: 100,
            height: 40,
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(showOptionalUpdateDialogProvider.notifier).state = false;
              navigateAfterSplash(route);
            },
          ),
          CustomFilledButton(
            text: 'Update'.tr,
            width: 100,
            height: 40,
            color: AppColor.primary,
            onPressed: () async {
              if (storeLink.isNotEmpty &&
                  await canLaunchUrl(Uri.parse(storeLink))) {
                await launchUrlString(
                  storeLink,
                  mode: LaunchMode.externalApplication,
                );
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
              ref.read(showOptionalUpdateDialogProvider.notifier).state = false;
              navigateAfterSplash(route);
            },
          ),
        ],
      ),
    );
  }
}
