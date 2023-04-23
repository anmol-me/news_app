import 'dart:ui';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/router.dart';
import 'package:news_app/common/constants.dart';

import 'features/authentication/repository/auth_repo.dart';

import 'package:string_validator/string_validator.dart';

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
  // WidgetsFlutterBinding.ensureInitialized();
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

// final prefs = SharedPreferences.getInstance();
// final String? authData = prefs.g;

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//
//
//
//   }
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//     init();
//   }
//
//   Future init() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//   }
// }

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // late SharedPreferences prefs;
  // String? authData;

  // Future init() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   authData = prefs.getString('basicAuth');
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   // authData = UserPreferences.getAuthData();
  // }

  @override
  Widget build(BuildContext context) {
    // String? authData = prefs.getString('basicAuth');
    // final isLogin = ref.watch(isLoginProvider);

    // log('AUTH-DATA: $authData');

    final themeMode = ref.watch(themeModeProvider);

    // final ThemeMode themeMode;
    // final got = ref.watch(userSettingsProvider.notifier).getThemeMode();
    // if (got == null || got) {
    //   log(got.toString());
    //   themeMode = ThemeMode.dark;
    //   log(themeMode.toString());
    // } else {
    //   themeMode = ThemeMode.light;
    //   log(themeMode.toString());
    // }

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
      // home: const SubscriptionListScreen(),
      // home: const CategoryScreen(),
      // home: const NewsDetailsScreen(),
      // home: const HomeFeedScreen(),
      // home: const SelectSubscriptionScreen(),
      // home: authRepo.isAuth ? const AuthScreen() : const HomeFeedScreen(),
      // onGenerateRoute: (settings) => onGenerateRoute(settings),
      routerConfig: ref.read(goRouterProvider),
    );
  }
}