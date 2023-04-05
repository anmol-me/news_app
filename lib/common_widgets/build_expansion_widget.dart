import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/common/frontend_methods.dart';
import 'package:news_app/common_widgets/top_section_row.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/common_widgets.dart';
import '../common/constants.dart';
import '../common/enums.dart';
import '../models/news.dart';
import '../features/home/repository/home_feed_repo.dart';
import '../features/home/screens/home_feed_screen.dart';
import 'expansion_widget.dart';
import 'package:news_app/features/details/screens/news_details_screen.dart';

Widget buildExpansionWidget(
  News newsItem,
  String dateTime,
  BuildContext context,
  HomeFeedNotifier newsNotifierController,
  WidgetRef ref,
) {
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
                placeholder: (context, url) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: colorRed,
                      strokeWidth: 1,
                    ),
                  );
                },
                errorWidget: (
                  context,
                  url,
                  error,
                ) =>
                    //     Image.network(
                    //   ErrorString.image.value,
                    //   height: 90,
                    //   width: 120,
                    //   fit: BoxFit.cover,
                    // ),
                    Image.asset(
                  'assets/notfound.png',
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
                  log('ENTRY: ${newsItem.entryId}');

                  // if (kIsWeb) {

                  // final uri = Uri.parse(newsItem.link);
                  //
                  // if (await canLaunchUrl(uri)) {
                  //   await launchUrl(uri);
                  // } else {
                  //   if (context.mounted) {
                  //     showDialog(
                  //       context: context,
                  //       builder: (ctx) => AlertDialog(
                  //         title: const Text('An Error Occurred!'),
                  //         content: const Text('Could not load the page.'),
                  //         actions: [
                  //           TextButton(
                  //             onPressed: () {
                  //               Navigator.of(ctx).pop();
                  //             },
                  //             child: const Text('Okay'),
                  //           ),
                  //         ],
                  //       ),
                  //     );
                  //   }
                  // }
                  // } else {
                  //
                  // }

                  newsNotifierController.toggleRead(
                    newsItem.entryId,
                    Status.read,
                    context,
                  );

                  context.pushNamed(
                    NewsDetailsScreen.routeNamed,
                    queryParams: {
                      'id': newsItem.entryId.toString(),
                      'image': newsItem.imageUrl,
                      'content': newsItem.content,
                      'categoryTitle': newsItem.categoryTitle,
                      'title': newsItem.titleText,
                      'link': newsItem.link,
                      'publishedAt': newsItem.publishedTime.toString(),
                    },
                  );

                  /// Todo: Nav
                  // Navigator.of(context).pushNamed(
                  //   NewsDetailsScreen.routeNamed,
                  //   arguments: {
                  //     'id': newsItem.entryId,
                  //     'image': newsItem.imageUrl,
                  //     'content': newsItem.content,
                  //     'categoryTitle': newsItem.categoryTitle,
                  //     'title': newsItem.titleText,
                  //     'link': newsItem.link,
                  //     'publishedAt': newsItem.publishedTime,
                  //   },
                  // );
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
            StarredButton(entryId: newsItem.entryId),
            const SizedBox(width: 30),
            ReadButton(entryId: newsItem.entryId),
          ],
        ),
      ),
    ),
  );
}
