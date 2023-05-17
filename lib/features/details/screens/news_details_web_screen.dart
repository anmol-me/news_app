import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import '../../../common/constants.dart';
import '../../../components/app_button.dart';
import '../../../components/read_button.dart';
import '../../../models/news.dart';
import '../../authentication/repository/user_preferences.dart';
import '../../category/repository/category_repo.dart';
import '../../home/providers/home_providers.dart';
import '../../search/repository/search_repo.dart';
import '../components/card_header_row.dart';
import '../components/header_image.dart';
import '../components/providers.dart';

final fromSearchScreen = StateProvider((ref) => false);

class NewsDetailsWebScreen extends ConsumerWidget {
  static const routeNamed = '/web-details';

  final News newsItem;
  final String screenName;

  const NewsDetailsWebScreen({
    super.key,
    required this.newsItem,
    required this.screenName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFabButton = ref.watch(isFabButtonProvider);
    final isFabButtonController = ref.watch(isFabButtonProvider.notifier);

    final newsNotifier = ref.watch(homeFeedProvider);
    final categoryNotifier = ref.watch(categoryNotifierProvider);
    final searchNotifier = ref.watch(searchNotifierProvider);

    final newsController = ref.watch(homeFeedProvider.notifier);
    final categoryController = ref.watch(categoryNotifierProvider.notifier);
    final searchController = ref.watch(searchNotifierProvider.notifier);

    final newsDetails = ref.watch(newsDetailsProvider);

    bool isFav = false;

    if (screenName == 'search') {
      isFav = searchNotifier
          .firstWhere(
            (e) => e.entryId == newsItem.entryId,
          )
          .isFav;
    } else if (screenName == 'category') {
      isFav = categoryNotifier
          .firstWhere((e) => e.entryId == newsItem.entryId)
          .isFav;
    } else {
      isFav = newsNotifier
          .firstWhere(
            (e) => e.entryId == newsItem.entryId,
          )
          .isFav;
    }

    final feedDate = DateFormat.yMMMMd().format(newsItem.publishedTime);
    final feedTime = DateFormat.jm().format(newsItem.publishedTime);

    return Scaffold(
      appBar: AppBar(
        actions: [
          Row(
            children: [
              AppButton(
                'Open link',
                icon: Icons.link,
                onTap: () => newsDetails.openLink(newsItem.link, context),
              ),
              const SizedBox(width: 10),
              ReadButton(
                entryId: newsItem.entryId,
                screenName: screenName,
              ),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.forward) {
            isFabButtonController.update((state) => true);
          } else if (notification.direction == ScrollDirection.reverse) {
            if (isFabButton) {
              isFabButtonController.update((state) => false);
            }
          }
          return true;
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
                left: 8.0,
                right: 8.0,
                bottom: 8.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: CardHeaderRow(
                      categoryTitle: newsItem.categoryTitle,
                      feedDate: feedDate,
                      feedTime: feedTime,
                    ),
                  ),
                  Text(
                    newsItem.titleText,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  newsItem.imageUrl == ''
                      ? const SizedBox(height: 10)
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: HeaderImage(imageUrl: newsItem.imageUrl),
                        ),
                  Text(
                    newsItem.content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: isFabButton
          ? FloatingActionButton(
              backgroundColor: colorRed,
              onPressed: () {
                final isDemoPref =
                    ref.read(userPrefsProvider).getIsDemo() ?? false;
                if (!isDemoPref) {
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
                }
              },
              child: Icon(isFav ? Icons.bookmark_added : Icons.bookmark_add),
            )
          : null,
    );
  }
}
