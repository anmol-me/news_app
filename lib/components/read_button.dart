import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/enums.dart';
import '../features/authentication/repository/user_preferences.dart';
import '../features/category/repository/category_repo.dart';
import '../features/home/providers/home_providers.dart';
import '../features/search/repository/search_repo.dart';
import '../models/news.dart';
import 'app_button.dart';

class ReadButton extends ConsumerWidget {
  final int entryId;
  final String screenName;

  const ReadButton({
    super.key,
    required this.entryId,
    required this.screenName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsNotifier = ref.watch(homeFeedProvider);
    final categoryNotifier = ref.watch(categoryNotifierProvider);
    final searchNotifier = ref.watch(searchNotifierProvider);

    final newsController = ref.watch(homeFeedProvider.notifier);
    final categoryController = ref.watch(categoryNotifierProvider.notifier);
    final searchController = ref.watch(searchNotifierProvider.notifier);

    News newsItem;

    if (screenName == 'search') {
      newsItem = searchNotifier.firstWhere(
            (e) => e.entryId == entryId,
      );
    } else if (screenName == 'category') {
      newsItem = categoryNotifier.firstWhere(
            (e) => e.entryId == entryId,
      );
    } else {
      newsItem = newsNotifier.firstWhere(
            (e) => e.entryId == entryId,
      );
    }

    return AppButton(
      newsItem.status == Status.unread ? 'Unread' : 'Read',
      icon: newsItem.status == Status.unread
          ? Icons.circle
          : Icons.circle_outlined,
      onTap: () {
        final isDemoPref = ref.read(userPrefsProvider).getIsDemo() ?? false;
        if (isDemoPref) {
          return;
        }

        Status stat;

        newsItem.status == Status.read
            ? stat = Status.unread
            : stat = Status.read;

        if (screenName == 'search') {
          searchController.toggleRead(
            entryId,
            stat,
            context,
          );
        } else if (screenName == 'category') {
          categoryController.toggleRead(
            entryId,
            stat,
            context,
          );
        } else {
          newsController.toggleRead(
            entryId,
            stat,
            context,
          );
        }
      },
    );
  }
}