import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/constants.dart';
import '../features/authentication/repository/user_preferences.dart';
import '../features/category/repository/category_repo.dart';
import '../features/home/providers/home_providers.dart';
import '../features/search/repository/search_repo.dart';
import '../models/news.dart';
import 'app_button.dart';

class StarredButton extends ConsumerWidget {
  const StarredButton({
    super.key,
    required this.entryId,
    required this.screenName,
  });

  final int entryId;
  final String screenName;

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
      newsItem.isFav ? 'Unstar' : 'Star',
      icon: newsItem.isFav ? Icons.bookmark_added : Icons.bookmark_add,
      iconColor: colorAppbarForeground,
      onTap: () {
        final isDemoPref = ref.read(userPrefsProvider).getIsDemo() ?? false;
        if (isDemoPref) {
          return;
        }

        if (screenName == 'search') {
          searchController.toggleFavStatus(
            newsItem.entryId,
            context,
          );
        } else if (screenName == 'category') {
          categoryController.toggleFavStatus(
            newsItem.entryId,
            context,
          );
        } else {
          newsController.toggleFavStatus(
            newsItem.entryId,
            context,
          );
        }
      },
    );
  }
}