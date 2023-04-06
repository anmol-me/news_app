import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:news_app/common/common_widgets.dart';
import 'package:share_plus/share_plus.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common/constants.dart';
import '../../../models/news.dart';
import '../../home/repository/home_feed_repo.dart';
import '../components/card_header_row.dart';
import '../components/header_image.dart';
import '../components/methods.dart';
import '../components/providers.dart';

class NewsDetailsWebScreen extends ConsumerWidget {
  static const routeNamed = '/web-details';

  final News newsItem;

  const NewsDetailsWebScreen({
    super.key,
    required this.newsItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFabButton = ref.watch(isFabButtonProvider);
    final isFabButtonController = ref.watch(isFabButtonProvider.notifier);

    final newsNotifier = ref.watch(homeFeedProvider);
    final newsNotifierController = ref.watch(homeFeedProvider.notifier);

    var isFav = newsNotifier.firstWhere((e) => e.entryId == newsItem.entryId).isFav;

    final contentFormatted = getContent(newsItem.content);

    final feedDate = DateFormat.yMMMMd().format(newsItem.publishedTime);
    final feedTime = DateFormat.jm().format(newsItem.publishedTime);

    return Scaffold(
      appBar: AppBar(
        actions: [
          Row(
            children: [
              OpenLinkButton(url: newsItem.link),
              const SizedBox(width: 10),
              ReadButton(entryId: newsItem.entryId),
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
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  newsItem.imageUrl == ''
                      ? const SizedBox(height: 10)
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: HeaderImage(imageUrl: newsItem.imageUrl),
                        ),
                  Text(
                    contentFormatted,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // ),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: isFabButton
          ? FloatingActionButton(
              backgroundColor: colorRed,
              onPressed: () {
                newsNotifierController.toggleFavStatus(
                    newsItem.entryId, context);
              },
              child: Icon(
                  isFav ? Icons.bookmark_added : Icons.bookmark_add),
            )
          : null,
    );
  }
}
