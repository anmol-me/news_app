import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:news_app/common/common_providers.dart';

import 'package:news_app/features/home/repository/home_methods.dart';
import '../features/authentication/repository/user_preferences.dart';
import '../features/home/providers/home_providers.dart';
import '../features/home/screens/home_feed_screen.dart';
import '../models/news.dart';

final refreshProvider = Provider((ref) {
  return RefreshMethods(ref);
});

class RefreshMethods {
  final Ref ref;

  RefreshMethods(this.ref);

  Future<void> refreshAllMain(
    BuildContext context,
  ) async {
    final currentLocation = GoRouterState.of(context).name;

    final isDrawerOpened = ref.read(isDrawerOpenProvider);
    if (isDrawerOpened) Navigator.of(context).pop();

    final isDemoPref = ref.read(userPrefsProvider).getIsDemo() ?? false;
    if (isDemoPref) {
      ref.read(homeMethodsProvider(context)).refreshHomeProviders();
      ref.read(homeFeedProvider.notifier).fetchDemoEntries(context);

      if (currentLocation != '/home-feed-screen' &&
          currentLocation != '/home-web-screen') context.go('/home');

      return;
    }

    final isLoadingHomePageController =
        ref.read(homePageLoadingProvider.notifier);

    isLoadingHomePageController.update((state) => true);

    ref.read(homeMethodsProvider(context)).refreshHomeProviders();

    if (currentLocation == '/home-feed-screen' ||
        currentLocation == '/home-web-screen') {
      ref.refresh(homeFeedProvider.notifier).fetchEntries(context).then(
            (_) => isLoadingHomePageController.update((state) => false),
          );
    } else {
      isLoadingHomePageController.update((state) => false);
      context.pushNamed(HomeFeedScreen.routeNamed);
    }
  }
}

String getDate(News newsItem) {
  final dateFormatted = DateFormat('dd MMM yyyy').format(
    newsItem.publishedTime,
  );

  final now = DateFormat('dd MMM yyyy').format(
    DateTime.now(),
  );

  final yesterday = DateFormat('dd MMM yyyy').format(
    DateTime.now().subtract(const Duration(days: 1)),
  );

  final twoDaysAgo = DateFormat('dd MMM yyyy').format(
    DateTime.now().subtract(const Duration(days: 2)),
  );

  final todayTime = Jiffy.parse('${newsItem.publishedTime}').fromNow();

  var dateUsed = dateFormatted == now
      ? todayTime
      : dateFormatted == yesterday
          ? 'Yesterday'
          : dateFormatted == twoDaysAgo
              ? '2 days ago'
              : dateFormatted;

  return dateUsed;
}

DateTime getDateTime(info) {
  var time = info['published_at'];
  int startIndex = time.indexOf('T');
  int endIndex = time.indexOf('Z');

  final timeLoaded = time.substring(startIndex + 1, endIndex + "T".length - 1);
  final dateLoaded = time.substring(0, startIndex);

  return DateTime.parse('$dateLoaded $timeLoaded');
}

String getImageUrl(info) {
  final imageUrl =
      html_parser.parse(info['content']).getElementsByTagName('img');

  if (imageUrl.isNotEmpty) {
    final url = imageUrl[0].attributes['src'] ?? '';
    /// Add below url for cross proxy service
    final proxyImageUrl = '$url';
    if (kIsWeb) return proxyImageUrl;
    return url;
  } else {
    return '';
  }
}
