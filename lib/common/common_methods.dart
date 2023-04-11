import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

import '../features/home/providers/home_providers.dart';
import '../features/home/repository/home_feed_repo.dart';
import '../features/home/screens/home_feed_screen.dart';
import '../models/news.dart';

final isHomeDrawerOpened = StateProvider((ref) => false);

final refreshProvider = Provider((ref) {
  return RefreshMethods(ref);
});

class RefreshMethods {
  final ProviderRef ref;

  RefreshMethods(this.ref);

  Future<void> refreshAllMain(
    BuildContext context,
  ) async {
    final isLoadingHomePageController =
        ref.read(homePageLoadingProvider.notifier);

    final currentLocation = GoRouterState.of(context).name;

    log("Refresh ---> $currentLocation");
    final isDrawerOpened = ref.read(isHomeDrawerOpened);

    if (isDrawerOpened) {
      Navigator.of(context).pop();
      ref.read(isHomeDrawerOpened.notifier).update((state) => false);
    }

    isLoadingHomePageController.update((state) => true);

    refreshHomeProviders(ref);

    // if (ModalRoute.of(context)!.settings.name == '/') {
    if (currentLocation == '/home-feed-screen' ||
        currentLocation == '/home-web-screen') {
      log('HOME PAGE REFRESHED');
      ref.refresh(homeFeedProvider.notifier).fetchEntries(context).then(
            (_) => isLoadingHomePageController.update((state) => false),
          );
    } else {
      isLoadingHomePageController.update((state) => false);
      log('NOT HOME PAGE');

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
