import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:heraj/config/app_theme.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/setup_services.dart';
import 'package:heraj/ui/ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'config/app_routes.dart';
import 'config/app_string.dart';
import 'config/app_translation.dart';
import 'config/constants.dart';
import 'core/enum/language.dart';
import 'core/service/deep_linking_service/deep_linking_service.dart';
import 'core/service/shake_to_support_listener.dart';
import 'core/service/localization_service/localization_service.dart';
import 'core/service/notifications_service.dart';
import 'core/service/theme_mode_service.dart';
import 'features/share/presentation/managers/share_link_navigator.dart';
import 'features/offline/no_wifi.dart';
import 'features/splash/presentation/managers/splash_provider.dart';
import 'features/splash/presentation/view/splash_view.dart';
import 'firebase_options.dart';
import 'helper/responsive.dart';
import 'ui/shared_widgets/global_error_screen.dart';

final GetIt getIt = GetIt.instance;

final ProviderContainer providerContainer = ProviderContainer(
  observers: [
    if (kDebugMode && Constants.loggerRiverPod) const _Logger(),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (FlutterErrorDetails details) {
    try {
      return GlobalErrorScreen(details: details);
    } catch (_) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: const ColoredBox(
          color: Colors.white,
          child: Center(child: Text('Something went wrong')),
        ),
      );
    }
  };

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupLocator();
  await getIt<DeepLinkService>().init(
    onResolvedWhileRunning: (resolved) {
      // Warm links must stay on the current stack (no splash / offAll).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShareLinkNavigator.navigate(resolved);
        getIt<DeepLinkService>().clear();
      });
    },
  );
  await setupNotification();
  await Future.wait([
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
    if (!kIsWeb && Platform.isAndroid)
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge),
  ]);

  runApp(UncontrolledProviderScope(
    container: providerContainer,
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    responsiveInit(context);
    return ScreenUtilInit(
      fontSizeResolver: FontSizeResolvers.height,
      minTextAdapt: true,
      splitScreenMode: true,
      designSize: const Size(375, 812),
      builder: (context, child) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: GetMaterialApp(
            supportedLocales: Language.values.map((e) => e.locale).toList(),
            defaultTransition: Platform.isIOS ? Transition.cupertino : null,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            translations: Translation(),
            debugShowCheckedModeBanner: false,
            builder: (context, widget) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.noScaling),
              child: ShakeToSupportListener(
                child: Consumer(
                  child: widget,
                  builder: (context, ref, child) {
                    final hasConnection = ref.watch(isInternetOk);
                    return AnnotatedRegion<SystemUiOverlayStyle>(
                      value: UIHelper.getSystemOverlayStyle(
                          ref.watch(isDarkModeProvider)),
                      child: IndexedStack(
                        index: kDebugMode
                            ? 0
                            : hasConnection
                                ? 0
                                : 1,
                        children: [
                          child!,
                          const NoWifi(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            theme: getLightTheme(),
            darkTheme: getDarkTheme(),
            transitionDuration: Duration(milliseconds: 800),
            title: AppString.appName,
            locale: localeService.handleLocaleInMain,
            themeMode: ThemeMode.light,
            getPages: appRoutes,
            home: const SplashView(),
          ),
        );
      },
    );
  }
}

class _Logger extends ProviderObserver {
  const _Logger();

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    Logger().e(
      '''
{
  "provider": "${provider.name ?? provider.runtimeType}",
  "previousValue": "$previousValue",
  "newValue": "$newValue"
}''',
    );
  }
}
