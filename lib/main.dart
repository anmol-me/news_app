import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/config/gorouter/router.dart';
import 'package:news_app/themes.dart';
import 'package:universal_platform/universal_platform.dart';
import 'url_strategy/nonweb_url_strategy.dart'
    if (dart.library.html) 'url_strategy/web_url_strategy.dart';
import 'features/authentication/repository/user_preferences.dart';
import 'features/settings/repository/settings_repository.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  if (UniversalPlatform.isDesktop) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions =
        const WindowOptions(minimumSize: Size(430, 630));
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  await UserPreferences.init();
  await UserSettings.init();
  configureUrl();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final themeData = AppTheme();

    return MaterialApp.router(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      debugShowCheckedModeBanner: false,
      title: 'Open Feed',
      themeMode: themeMode,
      darkTheme: themeData.darkThemeData(),
      theme: themeData.lightThemeData(),
      routerConfig: ref.read(goRouterProvider),
    );
  }
}
