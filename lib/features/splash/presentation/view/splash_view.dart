import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/features/settings/presentation/manager/fetch_settings_manager.dart';
import 'package:heraj/features/splash/presentation/managers/splash_actions_mixin.dart';
import 'package:heraj/features/splash/presentation/managers/splash_gif_cache.dart';
import 'package:heraj/features/splash/presentation/managers/splash_navigation_mixin.dart';
import 'package:heraj/features/splash/presentation/managers/splash_provider.dart';
import 'package:heraj/features/splash/presentation/view/widgets/splash_gif_preload.dart';
import 'package:heraj/features/splash/presentation/view/widgets/splash_logo_content.dart';
import 'package:heraj/features/splash/presentation/view/widgets/update_required_body.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/shared_widgets/error_widget.dart';
import 'package:heraj/ui/shared_widgets/logo_widget.dart';

import '../../../../config/app_font.dart';
import '../../../../core/service/remote_config_service.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView>
    with TickerProviderStateMixin, SplashNavigationMixin, SplashActionsMixin {
  late final AnimationController logoController;
  late final AnimationController textController;
  late final Animation<double> logoProgress;
  late final Animation<double> logoRotation;
  late final Animation<double> textOpacity;

  @override
  void initState() {
    super.initState();
    logoController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    logoProgress = CurvedAnimation(
      parent: logoController,
      curve: Curves.easeOutCubic,
    );
    logoRotation = Tween<double>(begin: -0.75, end: 0).animate(
      CurvedAnimation(
        parent: logoController,
        curve: Curves.easeOutCubic,
      ),
    );

    textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    textOpacity = CurvedAnimation(
      parent: textController,
      curve: Curves.easeIn,
    );

    logoController.forward().whenComplete(() {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) textController.forward();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkRealDeviceOrExit();
    });
  }

  @override
  void dispose() {
    logoController.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(splashProvider);
    final settingsGifUrl =
        ref.watch(appSettingsProvider)?.mobileSplashGifUrl?.trim();

    ref.listen(appSettingsProvider, (previous, next) {
      final url = next?.mobileSplashGifUrl?.trim();
      if (url != null && url.isNotEmpty) {
        startGifPrecache(url);
      }
    });

    ref.listen(splashProvider, (previous, next) {
      if (previous?.hasValue == false && next.hasValue) {
        onSplashReady(next.value!);
      }
    });

    // Kick off / keep warming as soon as URL exists.
    if (settingsGifUrl != null &&
        settingsGifUrl.isNotEmpty &&
        !SplashGifCache.isReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) startGifPrecache(settingsGifUrl);
      });
    }

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          final isUpdateAvailable = ref.watch(isUpdateAvailableProvider);
          if (!isUpdateAvailable) return const SizedBox.shrink();
          return Text(
            '${'Loading some updates'.tr} ...',
            style: AppFont.font16W600Gray2,
          );
        },
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          provider.customWhen(
            refreshable: splashProvider.future,
            ref: ref,
            data: (data) {
              if (data == SplashNavigate.forceUpdate) {
                return UpdateRequiredBody(
                  storeLink: getIt<RemoteConfigService>().storeLink,
                );
              }
              return SplashLogoContent(
                logoProgress: logoProgress,
                logoRotation: logoRotation,
                textOpacity: textOpacity,
              );
            },
            error: (o, b) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const LogoWidget(),
                        CustomErrorWidget(
                          object: 'Oops!\nServer is under maintenance'.tr,
                          stackTrace: b,
                          onRetry: () => ref.refresh(splashProvider.future),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => SplashLogoContent(
              logoProgress: logoProgress,
              logoRotation: logoRotation,
              textOpacity: textOpacity,
            ),
          ),
          if (settingsGifUrl != null && settingsGifUrl.isNotEmpty)
            SplashGifPreload(gifUrl: settingsGifUrl),
        ],
      ),
    );
  }
}
