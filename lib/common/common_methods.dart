import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

import '../features/home/providers/home_providers.dart';
import '../features/home/repository/home_feed_repo.dart';
import '../models/news.dart';

Future<void> refreshAll(
  NavigatorState navigator,
  WidgetRef ref,
  BuildContext context,
  StateController<bool> isLoadingPageController,
) async {
  log(ModalRoute.of(context)!.settings.name.toString());
  isLoadingPageController.update((state) => true);

  refreshWidgetProviders(ref);

  if (ModalRoute.of(context)!.settings.name == '/') {
    ref.refresh(homeFeedProvider.notifier).fetchEntries(context).then(
          (_) => isLoadingPageController.update((state) => false),
        );
  } else {
    isLoadingPageController.update((state) => false);
    navigator.pushNamed('/');
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
