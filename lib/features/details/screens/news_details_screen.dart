import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:html/parser.dart';

import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:news_app/common/common_widgets.dart';
import 'package:news_app/common/enums.dart';
import 'package:share_plus/share_plus.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common/constants.dart';
import '../../home/repository/home_feed_repo.dart';

final isFabButtonProvider = StateProvider<bool>((ref) => true);

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

    /// Content
    // final contentStripped = Bidi.stripHtmlIfNeeded(content);
    final document = parse(content);
    final contentStripped = parse(document.body!.text).documentElement!.text;
    final contentFormatted = utf8.decode(contentStripped.runes.toList());

    final feedDate = DateFormat.yMMMMd().format(publishedAt);
    final feedTime = DateFormat.jm().format(publishedAt);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            // InkWell(
            //   onTap: () {
            //     Status stat;
            //
            //     newsItem.status == Status.read
            //         ? stat = Status.unread
            //         : stat = Status.read;
            //
            //     newsNotifierController.toggleRead(
            //       entryId,
            //       stat,
            //       context,
            //     );
            //   },
            //   child: Icon(
            //     size: 27,
            //     color: colorRed,
            //     newsItem.status == Status.unread
            //         ? Icons.circle
            //         : Icons.circle_outlined,
            //   ),
            // ),
            Row(
              children: [
                ReadButton(entryId: entryId),
                IconButton(
                  onPressed: () => Share.share(link),
                  icon: Icon(Icons.share, color: colorRed),
                ),
              ],
            )
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl!,
                                    height: MediaQuery.of(context).size.height *
                                        0.30,
                                    width: MediaQuery.of(context).size.width *
                                        0.90,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(
                                        color: colorRed,
                                        strokeWidth: 1,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Image.network(
                                      ErrorString.image.value,
                                      height: 90,
                                      width: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
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
              WebView(
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl: link,
                zoomEnabled: true,
                gestureRecognizers: {
                  Factory<VerticalDragGestureRecognizer>(
                      () => VerticalDragGestureRecognizer())
                },
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

class CardHeaderRow extends StatelessWidget {
  const CardHeaderRow({
    Key? key,
    required this.categoryTitle,
    required this.feedDate,
    required this.feedTime,
  }) : super(key: key);

  final String categoryTitle;
  final String feedDate;
  final String feedTime;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Text(
          categoryTitle,
          style: TextStyle(
            color: colorRed,
            fontSize: 15,
          ),
        ),
        Text(
          ' / ',
          style: TextStyle(
            color: colorSubtitle,
            fontSize: 15,
          ),
        ),
        Text(
          '$feedDate at $feedTime',
          style: TextStyle(
            color: colorSubtitle,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
