import 'dart:developer' show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:news_app/common/error_screen.dart';
import 'package:news_app/features/authentication/screens/auth_screen.dart';
import 'package:news_app/features/subscription/screens/add_subscription_screen.dart';
import 'package:news_app/features/category/screens/category_screen.dart';
import 'package:news_app/features/subscription/screens/edit_subscription_screen.dart';
import 'package:news_app/features/subscription/screens/select_subscription_screen.dart';
import 'package:news_app/features/details/screens/news_details_screen.dart';

import 'features/authentication/repository/auth_repo.dart';
import 'features/category/screens/edit_feed_screen.dart';
import 'features/category/screens/manage_category_screen.dart';
import 'features/details/screens/news_details_web_screen.dart';
import 'features/home/screens/home_feed_screen.dart';
import 'features/home/screens/home_web_screen.dart';
import 'features/search/screens/search_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'models/news.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider(
  (ref) {
    final authRepo = ref.watch(authRepoProvider);

    return GoRouter(
      debugLogDiagnostics: true,
      initialLocation: '/auth',
      navigatorKey: rootNavigatorKey,
      errorBuilder: (context, state) => ErrorScreen(message: state.error.toString()),
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
        GoRoute(
          path: '/home',
          name: HomeFeedScreen.routeNamed,
          builder: (context, state) {
            return kIsWeb ? const HomeWebScreen() : const HomeFeedScreen();
          },
        ),
        GoRoute(
          path: '/home-web-screen',
          name: HomeWebScreen.routeNamed,
          builder: (context, state) {
            return const HomeWebScreen();
          },
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
              return NewsDetailsWebScreen(newsItem: state.extra as News);
            } else {
              return NewsDetailsScreen(
                newsItem: state.extra as News,
                screenName: state.queryParams['screenName']!,
              );
            }
          },
        ),
        GoRoute(
          path: '/select-subs',
          name: SelectSubscriptionScreen.routeNamed,
          builder: (context, state) => const SelectSubscriptionScreen(),
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
