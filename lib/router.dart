import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


import 'package:news_app/common/error_screen.dart';
import 'package:news_app/features/app_bar/app_drawer.dart';
import 'package:news_app/features/authentication/screens/auth_screen.dart';
import 'package:news_app/features/starred/starred_screen.dart';
import 'package:news_app/features/subscription/screens/add_subscription_screen.dart';
import 'package:news_app/features/subscription/screens/category_screen.dart';
import 'package:news_app/features/subscription/screens/edit_subscription_screen.dart';
import 'package:news_app/features/subscription/screens/select_subscription_screen/select_subscription_screen.dart';
import 'package:news_app/features/details/screens/news_details_screen.dart';

import 'features/category/screens/edit_feed_screen.dart';
import 'features/category/screens/manage_category_screen.dart';
import 'features/home/screens/home_feed_screen.dart';
import 'features/search/screens/search_screen.dart';
import 'features/settings/screens/settings_screen.dart';

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



final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeFeedScreen(),
    ),
  ],
);