import 'dart:developer' show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:news_app/common/error_screen.dart';
import 'package:news_app/features/authentication/screens/auth_screen.dart';
import 'package:news_app/features/subscription/screens/add_subscription_screen.dart';
import 'package:news_app/features/subscription/screens/category_screen.dart';
import 'package:news_app/features/subscription/screens/edit_subscription_screen.dart';
import 'package:news_app/features/subscription/screens/select_subscription_screen/select_subscription_screen.dart';
import 'package:news_app/features/details/screens/news_details_screen.dart';

import 'features/authentication/repository/auth_repo.dart';
import 'features/category/screens/edit_feed_screen.dart';
import 'features/category/screens/manage_category_screen.dart';
import 'features/details/screens/news_details_web_screen.dart';
import 'features/home/screens/home_feed_screen.dart';
import 'features/home/screens/home_web_screen.dart';
import 'features/search/screens/search_screen.dart';
import 'features/settings/screens/settings_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

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

Route onGenerateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    /// Auth Screen
    case AuthScreen.routeNamed:
      return MaterialPageRoute(builder: (context) => const AuthScreen());

    /// Home Feed Screen
    case HomeFeedScreen.routeNamed:
      return MaterialPageRoute(builder: (context) => const HomeFeedScreen());

    /// Edit Feed Screen
    case EditFeedScreen.routeNamed:
      final arguments = routeSettings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => EditFeedScreen(
          oldFeedTitle: arguments['feedTitle'],
          feedId: arguments['feedId'],
          catId: arguments['catId'],
          listContext: arguments['listContext'],
        ),
      );

    /// News Details Screen
    case NewsDetailsScreen.routeNamed:
      // List<dynamic> args = routeSettings.arguments;
      final arguments = routeSettings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => NewsDetailsScreen(
          title: arguments['title'],
          categoryTitle: arguments['categoryTitle'],
          content: arguments['content'],
          entryId: arguments['id'],
          imageUrl: arguments['image'],
          link: arguments['link'],
          publishedAt: arguments['publishedAt'],
        ),
      );

    /// Subscription List Screen
    case SelectSubscriptionScreen.routeNamed:
      return MaterialPageRoute(
          builder: (context) => const SelectSubscriptionScreen());

    /// Category Screen
    case CategoryScreen.routeNamed:
      // List<dynamic> args = routeSettings.arguments;
      final arguments = routeSettings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => CategoryScreen(
          catId: arguments['id'],
          catTitle: arguments['catTitle'],
          isBackButton: arguments['isBackButton'],
        ),
      );

    /// Add Subscription Screen
    case AddSubscription.routeNamed:
      return MaterialPageRoute(builder: (context) => const AddSubscription());

    /// Edit Category Screen
    case EditSubscriptionScreen.routeNamed:
      // List<dynamic> args = routeSettings.arguments;
      final arguments = routeSettings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => EditSubscriptionScreen(
          oldTitle: arguments['oldTitle'],
          listItemId: arguments['listItemId'],
        ),
      );

    // /// Manage Categories Screen
    // case AllFeedsScreen.routeNamed:
    //   // final arguments = routeSettings.arguments as Map<String, dynamic>;
    //   return MaterialPageRoute(
    //       builder: (context) => AllFeedsScreen(
    //           // oldTitle: arguments['oldTitle'],
    //           // listItemId: arguments['listItemId'],
    //           ));

    /// Show Category Feeds Screen
    // case ManageCategoryScreen.routeNamed:
    //   final arguments = routeSettings.arguments as Map<String, dynamic>;
    //   return MaterialPageRoute(
    //       builder: (context) => ManageCategoryScreen(
    //             catListItem: arguments['listItem'],
    //             // oldTitle: arguments['oldTitle'],
    //           ));

    /// Search Screen
    case SearchScreen.routeNamed:
      return MaterialPageRoute(builder: (context) => const SearchScreen());

    /// Settings Screen
    case SettingsScreen.routeNamed:
      // final arguments = routeSettings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => const SettingsScreen(
            // oldTitle: arguments['oldTitle'],
            ),
      );

    /// Error Screen
    case ErrorScreen.routeNamed:
      final arguments = routeSettings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => ErrorScreen(
          message: arguments['message'],
        ),
      );

    /// Default
    default:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Scaffold(
          body: Center(child: Text('Screen does not exist!')),
        ),
      );
  }
}
