import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

import '../features/home/providers/home_providers.dart';
import '../features/home/repository/home_feed_repo.dart';
import '../models/news.dart';

Future<void> refreshAll(
  // NavigatorState navigator,
  WidgetRef ref,
  BuildContext context,
  StateController<bool> isLoadingPageController,
) async {
  final currentLocation = GoRouterState.of(context).name;
  // Todo: GoRouter cleanup
  // log(ModalRoute.of(context)!.settings.name.toString());
  log(currentLocation.toString());
  isLoadingPageController.update((state) => true);

  refreshWidgetProviders(ref);

  // if (ModalRoute.of(context)!.settings.name == '/') {
  if (currentLocation == '/home' || currentLocation == '/home-web-screen') {
    log('refreshed');
    ref.refresh(homeFeedProvider.notifier).fetchEntries(context).then(
          (_) => isLoadingPageController.update((state) => false),
        );
  } else {
    isLoadingPageController.update((state) => false);
    log('not home page');

    if (kIsWeb) {
      log('is web');
      context.pushNamed('/home-web-screen');
    } else {
      context.pushNamed('/home');
    }

    // Todo: Navigator
    // navigator.pushNamed('/');
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
