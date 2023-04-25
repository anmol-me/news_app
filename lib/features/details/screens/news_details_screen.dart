import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:news_app/common/common_widgets.dart';
import 'package:share_plus/share_plus.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common/constants.dart';
import '../../../models/news.dart';
import '../../home/providers/home_providers.dart';
import '../../search/repository/search_repo.dart';
import '../components/card_header_row.dart';
import '../components/header_image.dart';
import '../components/methods.dart';
import '../components/providers.dart';

class NewsDetailsScreen extends ConsumerWidget {
  static const routeNamed = '/details';

  final News newsItem;
  final String screenName;

  const NewsDetailsScreen({
    super.key,
    required this.newsItem,
    required this.screenName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFabButton = ref.watch(isFabButtonProvider);
    final isFabButtonController = ref.watch(isFabButtonProvider.notifier);

    var newsNotifier = ref.watch(homeFeedProvider);
    var newsNotifierController = ref.watch(homeFeedProvider.notifier);

    bool isFav = false;

    if (screenName == 'search') {
      isFav = ref
          .watch(searchNotifierProvider)
          .firstWhere((e) => e.entryId == newsItem.entryId)
          .isFav;
    } else {
      isFav =
          newsNotifier.firstWhere((e) => e.entryId == newsItem.entryId).isFav;
    }

    final contentFormatted = getContent(newsItem.content);

    final feedDate = DateFormat.yMMMMd().format(newsItem.publishedTime);
    final feedTime = DateFormat.jm().format(newsItem.publishedTime);

    final webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(newsItem.link));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Row(
              children: [
                ReadButton(
                  entryId: newsItem.entryId,
                  screenName: screenName,
                ),
                IconButton(
                  onPressed: () => Share.share(newsItem.link),
                  icon: Icon(Icons.share, color: colorRed),
                ),
              ],
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text(
                  'Article',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Tab(
                child: Text(
                  'Web View',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
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
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SafeArea(
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
              WebViewWidget(
                controller: webController,
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: isFabButton
            ? FloatingActionButton(
                backgroundColor: colorRed,
                onPressed: () {
                  if (screenName == 'search') {
                    ref
                        .read(searchNotifierProvider.notifier)
                        .toggleFavStatus(newsItem.entryId, context);
                  } else {
                    newsNotifierController.toggleFavStatus(
                        newsItem.entryId, context);
                  }
                },
                child: Icon(isFav ? Icons.bookmark_added : Icons.bookmark_add),
              )
            : null,
      ),
    );
  }
}
