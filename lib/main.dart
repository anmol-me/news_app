import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:news_app/common/constants.dart';
import 'features/authentication/repository/user_preferences.dart';
import 'features/settings/repository/settings_repository.dart';

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
  await UserPreferences.init();
  await UserSettings.init();
  usePathUrlStrategy();
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
        primarySwatch: Colors.red,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: colorRed,
        ),

        /// Todo: Change in Auth
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorRed,
          ),
        ),
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