import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:universal_platform/universal_platform.dart';

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
      initialLocation: '/',
      navigatorKey: rootNavigatorKey,
      errorBuilder: (context, state) => ErrorScreen(
        message: state.error.toString(),
      ),
      routes: [
        GoRoute(
          path: '/error-screen',
          name: ErrorScreen.routeNamed,
          builder: (context, state) => ErrorScreen(
            message: state.queryParameters['message']!,
          ),
        ),
        GoRoute(
          path: '/',
          name: AuthScreen.routeNamed,
          builder: (context, state) => const AuthScreen(),
          redirect: (BuildContext context, state) {
            return authRepo.isAuthenticated ? '/home' : '/';
          },
        ),
        GoRoute(
          path: '/home',
          name: HomeFeedScreen.routeNamed,
          builder: (context, state) {
            if (UniversalPlatform.isDesktop || UniversalPlatform.isWeb) {
              return const HomeWebScreen();
            } else {
              return const HomeFeedScreen();
            }
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
            if (UniversalPlatform.isDesktop || UniversalPlatform.isWeb) {
              return NewsDetailsWebScreen(
                newsItem: state.extra as News,
                screenName: state.queryParameters['from']!,
              );
            } else {
              return NewsDetailsScreen(
                newsItem: state.extra as News,
                screenName: state.queryParameters['from']!,
              );
            }
          },
        ),
        GoRoute(
          path: '/select-subs',
          name: SelectSubscriptionScreen.routeNamed,
          builder: (context, state) => const SelectSubscriptionScreen(),
          routes: [
            GoRoute(
              path: 'add-category',
              name: AddSubscription.routeNamed,
              builder: (context, state) => const AddSubscription(),
            ),
          ],
        ),
        GoRoute(
          path: '/category-screen',
          name: CategoryScreen.routeNamed,
          builder: (context, state) {
            return CategoryScreen(
              catId: int.parse(state.queryParameters['id']!),
              catTitle: state.queryParameters['catTitle']!,
              isBackButton: state.queryParameters['isBackButton']! != 'false',
              // Will not have back button
            );
          },
        ),
        GoRoute(
          path: '/edit-subs-screen',
          name: EditSubscriptionScreen.routeNamed,
          builder: (context, state) {
            return EditSubscriptionScreen(
              oldTitle: state.queryParameters['oldTitle']!,
              listItemId: int.parse(state.queryParameters['listItemId']!),
            );
          },
        ),
        GoRoute(
          path: '/manage-category-screen',
          name: ManageCategoryScreen.routeNamed,
          builder: (context, state) {
            return ManageCategoryScreen(
              catListItemId: int.parse(state.queryParameters['catListItemId']!),
              catListItemTitle: state.queryParameters['catListItemTitle']!,
            );
          },
        ),
        GoRoute(
          path: '/edit-feed-screen',
          name: EditFeedScreen.routeNamed,
          builder: (context, state) => EditFeedScreen(
            oldFeedTitle: state.queryParameters['feedTitle']!,
            feedId: int.parse(state.queryParameters['feedId']!),
            catId: int.parse(state.queryParameters['catId']!),
            listContext: state.extra! as BuildContext,
          ),
        ),
      ],
    );
  },
);
