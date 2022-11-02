import 'dart:developer' show log;

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
import 'features/subscription/screens/select_subscription_screen.dart';
import 'features/details/screens/news_details_screen.dart';
import 'features/home/screens/home_feed_screen.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await UserPreferences.init();
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
    final authRepo = ref.watch(authRepoProvider);
    // final isLogin = ref.watch(isLoginProvider);

    // log('AUTH-DATA: $authData');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: colorRed,
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
      home: authRepo.isAuth ? const AuthScreen() : const HomeFeedScreen(),
      onGenerateRoute: (settings) => onGenerateRoute(settings),
    );
  }
}
