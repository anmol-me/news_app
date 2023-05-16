import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/router.dart';
import 'package:universal_platform/universal_platform.dart';
import 'url_strategy/nonweb_url_strategy.dart'
    if (dart.library.html) 'url_strategy/web_url_strategy.dart';
import 'package:news_app/common/constants.dart';
import 'features/authentication/repository/user_preferences.dart';
import 'features/settings/repository/settings_repository.dart';
import 'package:window_manager/window_manager.dart';

final themeModeProvider = Provider<ThemeMode>((ref) {
  final isDarkModeEnabled = ref.watch(userSettingsProvider);

  if (isDarkModeEnabled == null) {
    return ThemeMode.light;
  } else if (isDarkModeEnabled) {
    return ThemeMode.dark;
  } else {
    return ThemeMode.light;
  }
});

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
      // Todo: Set name
      title: 'Open Feed',
      themeMode: themeMode,
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          background: Colors.grey.shade50,
          surface: Colors.grey.shade50,
          surfaceTint: Colors.grey.shade50,
          outline: Colors.black54,
        ),
        //
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: colorAppbarForeground,
          selectionColor: Colors.red.shade100,
        ),
        //
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorRed,
            foregroundColor: Colors.white,
          ),
        ),
        //
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: colorRed,
            foregroundColor: Colors.white,
          ),
        ),
        //
        appBarTheme: AppBarTheme(
          color: colorAppbarBackground,
          foregroundColor: colorAppbarForeground,
          elevation: 0,
        ),
      ),
      routerConfig: ref.read(goRouterProvider),
    );
  }
}
