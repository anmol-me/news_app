import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:news_app/common/common_widgets.dart';
import 'package:share_plus/share_plus.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common/constants.dart';
import '../../home/repository/home_feed_repo.dart';
import '../components/card_header_row.dart';
import '../components/header_image.dart';
import '../components/methods.dart';
import '../components/providers.dart';

class NewsDetailsScreen extends ConsumerWidget {
  static const routeNamed = '/details';

  final String title;
  final String categoryTitle;
  final String link;
  final String content;
  final int entryId;
  final String? imageUrl;
  final DateTime publishedAt;

  const NewsDetailsScreen({
    super.key,
    required this.title,
    required this.categoryTitle,
    required this.link,
    required this.content,
    required this.entryId,
    required this.imageUrl,
    required this.publishedAt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFabButton = ref.watch(isFabButtonProvider);
    final isFabButtonController = ref.watch(isFabButtonProvider.notifier);

    final newsNotifier = ref.watch(homeFeedProvider);
    final newsNotifierController = ref.watch(homeFeedProvider.notifier);

    var newsItem = newsNotifier.firstWhere((e) => e.entryId == entryId);

    final contentFormatted = getContent(content);

    final feedDate = DateFormat.yMMMMd().format(publishedAt);
    final feedTime = DateFormat.jm().format(publishedAt);

    final webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(link));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Row(
              children: [
                ReadButton(entryId: entryId),
                IconButton(
                  onPressed: () => Share.share(link),
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
                            categoryTitle: categoryTitle,
                            feedDate: feedDate,
                            feedTime: feedTime,
                          ),
                        ),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        imageUrl == null || imageUrl == ''
                            ? const SizedBox(height: 10)
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: HeaderImage(imageUrl: imageUrl),
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
              // WebView(
              //   javascriptMode: JavascriptMode.unrestricted,
              //   initialUrl: link,
              //   zoomEnabled: true,
              //   gestureRecognizers: {
              //     Factory<VerticalDragGestureRecognizer>(
              //         () => VerticalDragGestureRecognizer())
              //   },
              // ),
              WebViewWidget(
                controller: webController,
              ),
            ],
            // child: isWeb
            //     ?
            //     : ,
          ),
        ),
        // ),
        // ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: isFabButton
            ? FloatingActionButton(
                backgroundColor: colorRed,
                onPressed: () {
                  newsNotifierController.toggleFavStatus(entryId, context);
                },
                child: Icon(
                    newsItem.isFav ? Icons.bookmark_added : Icons.bookmark_add),
              )
            : null,
      ),
    );
  }
}



