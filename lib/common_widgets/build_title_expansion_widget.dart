import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/components/read_button.dart';
import 'package:news_app/components/starred_button.dart';
import 'package:news_app/common_widgets/top_section_row.dart';
import 'package:news_app/features/category/repository/category_repo.dart';

import '../common/common_methods.dart';
import '../features/authentication/repository/user_preferences.dart';
import '../features/home/providers/home_providers.dart';
import 'common_widgets.dart';
import '../common/constants.dart';
import '../common/enums.dart';
import '../features/search/repository/search_repo.dart';
import '../models/news.dart';
import 'expansion_widget.dart';
import 'package:news_app/features/details/screens/news_details_screen.dart';

Widget buildTileExpansionWidget(
  String screenName,
  News newsItem,
  BuildContext context,
  WidgetRef ref,
) {
  final dateTime = getDate(newsItem);

  final newsController = ref.read(homeFeedProvider.notifier);
  final categoryController = ref.read(categoryNotifierProvider.notifier);
  final searchController = ref.read(searchNotifierProvider.notifier);

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
        child: GestureDetector(
          onTap: () async {
            final isDemoPref = ref.read(userPrefsProvider).getIsDemo() ?? false;

            if (!isDemoPref) {
              if (screenName == 'search') {
                searchController.toggleRead(
                  newsItem.entryId,
                  Status.read,
                  context,
                );
              } else if (screenName == 'category') {
                categoryController.toggleRead(
                  newsItem.entryId,
                  Status.read,
                  context,
                );
              } else {
                newsController.toggleRead(
                  newsItem.entryId,
                  Status.read,
                  context,
                );
              }
            }

            context.pushNamed(
              NewsDetailsScreen.routeNamed,
              queryParameters: {'from': screenName},
              pathParameters: {'title' : newsItem.titleText},
              extra: newsItem,
            );
          },
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      newsItem.titleText,
                      style: Theme.of(context).textTheme.titleMedium,
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
            ],
          ),
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
