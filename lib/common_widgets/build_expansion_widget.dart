import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/common_widgets/top_section_row.dart';

import '../common/common_methods.dart';
import '../features/authentication/repository/user_preferences.dart';
import 'common_widgets.dart';
import '../common/constants.dart';
import '../common/enums.dart';
import '../features/search/repository/search_repo.dart';
import '../models/news.dart';
import '../features/home/repository/home_feed_repo.dart';
import 'expansion_widget.dart';
import 'package:news_app/features/details/screens/news_details_screen.dart';

Widget buildExpansionWidget(
  String screenName,
  News newsItem,
  BuildContext context,
  HomeFeedNotifier newsNotifierController,
  WidgetRef ref,
) {
  final dateTime = getDate(newsItem);

  return Padding(
    padding: const EdgeInsets.only(
      top: 5,
      bottom: 5,
      left: 16,
      right: 16,
    ),
    child: ExpansionWidget(
      topSection: topSectionRow(
        newsItem,
        dateTime,
        ref,
        context,
      ),
      titleSection: Padding(
        padding: const EdgeInsets.only(
          top: 8.0,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: CachedNetworkImage(
                imageUrl: newsItem.imageUrl,
                height: 90,
                width: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularLoadingImage(),
                ),
                errorWidget: (
                  context,
                  url,
                  error,
                ) =>
                    Image.asset(
                  Constants.imageNotFoundUrl.value,
                  height: 90,
                  width: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final isDemoPref =
                      ref.read(userPrefsProvider).getIsDemo() ?? false;

                  if (!isDemoPref) {
                    if (screenName == 'search') {
                      ref.read(searchNotifierProvider.notifier).toggleRead(
                            newsItem.entryId,
                            Status.read,
                            context,
                          );
                    } else {
                      newsNotifierController.toggleRead(
                        newsItem.entryId,
                        Status.read,
                        context,
                      );
                    }
                  }

                  context.pushNamed(
                    NewsDetailsScreen.routeNamed,
                    extra: newsItem,
                    queryParameters: {'screenName': screenName},
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      newsItem.titleText,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 4.0,
                      ),
                      child: Text(
                        '${newsItem.readTime} min read',
                        style: TextStyle(
                          color: colorAppbarForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      onExpanded: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Row(
          children: [
            StarredButton(
              entryId: newsItem.entryId,
              screenName: screenName,
            ),
            const SizedBox(width: 30),
            ReadButton(
              entryId: newsItem.entryId,
              screenName: screenName,
            ),
          ],
        ),
      ),
    ),
  );
}
