import 'dart:developer' show log;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:news_app/common/error_screen.dart';
import 'package:news_app/responsive/responsive_app.dart';
import 'package:string_validator/string_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/features/authentication/screens/auth_screen.dart';
import 'package:news_app/features/subscription/screens/add_subscription_screen.dart';
import 'package:news_app/features/subscription/screens/category_screen.dart';
import 'package:news_app/router.dart';
import 'package:news_app/common/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/authentication/repository/auth_repo.dart';
import 'features/category/screens/edit_feed_screen.dart';
import 'features/category/screens/manage_category_screen.dart';
import 'features/details/screens/news_details_web_screen.dart';
import 'features/home/screens/home_web_screen.dart';
import 'features/search/screens/search_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/subscription/screens/edit_subscription_screen.dart';
import 'features/subscription/screens/select_subscription_screen/select_subscription_screen.dart';
import 'features/details/screens/news_details_screen.dart';
import 'features/home/screens/home_feed_screen.dart';

import 'package:go_router/go_router.dart';

import 'models/model.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

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

final goRouterProvider = Provider(
  (ref) {
    final authRepo = ref.watch(authRepoProvider);

    return GoRouter(
      debugLogDiagnostics: true,
      initialLocation: '/auth',
      navigatorKey: rootNavigatorKey,
      routes: [
        GoRoute(
          path: '/error-screen',
          name: ErrorScreen.routeNamed,
          builder: (context, state) => ErrorScreen(
            message: state.queryParams['message']!,
          ),
        ),
        GoRoute(
          path: '/auth',
          name: AuthScreen.routeNamed,
          redirect: (BuildContext context, state) {
            log('AUTH-> isAuth: ${authRepo.isAuthenticated}');

            return authRepo.isAuthenticated ? '/home' : null;
          },
          builder: (context, state) => const AuthScreen(),
        ),
        // GoRoute(
        //   path: '/responsive',
        //   name: ResponsiveApp.routeNamed,
        //   builder: (context, state) => const ResponsiveApp(),
        // ),
        GoRoute(
          path: '/home',
          name: HomeFeedScreen.routeNamed,
          builder: (context, state) {
            return kIsWeb ? const HomeWebScreen() : const HomeFeedScreen();
          },
          // builder: (context, state) {
          //   if (kIsWeb) {
          //     return const HomeWebScreen();
          //   } else {
          //     return const HomeFeedScreen();
          //   }
          //
          //   // return const HomeFeedScreen();
          // },
          // redirect: (BuildContext context, state) {
          //   log('HOME-> isAuth: ${authRepo.isAuthenticated}');
          //
          //   return authRepo.isAuthenticated ? null : '/auth';
          // },
        ),
        GoRoute(
          path: '/search',
          name: SearchScreen.routeNamed,
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: SettingsScreen.routeNamed,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/details',
          name: NewsDetailsScreen.routeNamed,
          builder: (context, state) {
            if (kIsWeb) {
              return NewsDetailsWebScreen(
                title: state.queryParams['title']!,
                categoryTitle: state.queryParams['categoryTitle']!,
                link: state.queryParams['link']!,
                content: state.queryParams['content']!,
                entryId: int.parse(state.queryParams['id']!),
                imageUrl: state.queryParams['image']!,
                publishedAt: DateTime.parse(state.queryParams['publishedAt']!),
              );
            } else {
              return NewsDetailsScreen(
                title: state.queryParams['title']!,
                categoryTitle: state.queryParams['categoryTitle']!,
                link: state.queryParams['link']!,
                content: state.queryParams['content']!,
                entryId: int.parse(state.queryParams['id']!),
                imageUrl: state.queryParams['image']!,
                publishedAt: DateTime.parse(state.queryParams['publishedAt']!),
              );
            }
          },
        ),
        GoRoute(
          path: '/select-subs',
          name: SelectSubscriptionScreen.routeNamed,
          builder: (context, state) => const SelectSubscriptionScreen(),
          // redirect: (BuildContext context, state) {
          //   log('Subs-> isAuth: ${authRepo.isAuthenticated}');
          //
          //   return authRepo.isAuthenticated ? null : '/auth';
          // },
        ),
        GoRoute(
          path: '/category-screen',
          name: CategoryScreen.routeNamed,
          builder: (context, state) {
            return CategoryScreen(
              catId: int.parse(state.queryParams['id']!),
              catTitle: state.queryParams['catTitle']!,
              isBackButton: state.queryParams['isBackButton']! != 'false',
              // Will not have button button
            );
          },
        ),
        GoRoute(
          path: '/edit-subs-screen',
          name: EditSubscriptionScreen.routeNamed,
          builder: (context, state) {
            return EditSubscriptionScreen(
              oldTitle: state.queryParams['oldTitle']!,
              listItemId: int.parse(state.queryParams['listItemId']!),
            );
          },
        ),
        GoRoute(
          path: '/manage-category-screen',
          name: ManageCategoryScreen.routeNamed,
          builder: (context, state) {
            return ManageCategoryScreen(
              catListItemId: int.parse(state.queryParams['catListItemId']!),
              catListItemTitle: state.queryParams['catListItemTitle']!,
            );
          },
        ),
        GoRoute(
          path: '/edit-feed-screen',
          name: EditFeedScreen.routeNamed,
          builder: (context, state) => EditFeedScreen(
            oldFeedTitle: state.queryParams['feedTitle']!,
            feedId: int.parse(state.queryParams['feedId']!),
            catId: int.parse(state.queryParams['catId']!),
            listContext: state.extra! as BuildContext,
          ),
        ),
        GoRoute(
          path: '/add-category',
          name: AddSubscription.routeNamed,
          builder: (context, state) => const AddSubscription(),
        ),
      ],
    );
  },
);

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
      title: 'Flutter Demo',
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

// flutter run -d chrome --web-browser-flag "--disable-web-security"
