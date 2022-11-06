import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/common/enums.dart';
import 'package:news_app/features/starred/starred_screen.dart';

import '../../common/backend_methods.dart';
import '../../common/frontend_methods.dart';
import '../../models/news.dart';
import '../authentication/repository/auth_repo.dart';
import '../home/providers/home_providers.dart';

final starredNotifierProvider =
    StateNotifierProvider<StarredNotifier, List<News>>((ref) {
  //
  final userPrefs = ref.read(userPrefsProvider);
  final userPassEncoded = userPrefs.getAuthData();
  final url = userPrefs.getUrlData();

  var orderBy = ref.read(homeOrderProvider);
  final direction = ref.read(homeSortDirectionProvider);
  var starredOffset = ref.read(starredOffsetProvider);

  final isRead = ref.read(homeIsShowReadProvider);

  return StarredNotifier(
    userPrefs: userPrefs,
    ref: ref,
    baseUrl: url!,
    userPassEncoded: userPassEncoded!,
    orderBy: orderBy,
    direction: direction,
    starredOffset: starredOffset,
    // isStarred: isStarred,
    isRead: isRead,
  );
});

class StarredNotifier extends StateNotifier<List<News>> {
  final UserPreferences userPrefs;
  final StateNotifierProviderRef ref;
  final String baseUrl;
  final String userPassEncoded;
  final OrderBy orderBy;
  final Sort direction;
  final int starredOffset;

  // final bool isStarred;
  final bool isRead;

  StarredNotifier({
    required this.userPrefs,
    required this.ref,
    required this.baseUrl,
    required this.userPassEncoded,
    required this.orderBy,
    required this.direction,
    required this.starredOffset,
    // required this.isStarred,
    required this.isRead,
  }) : super([]);

  /// Fetch Bookmarks
  Future<void> fetchStarredEntries(BuildContext context) async {
    log('Fetching starred thro $baseUrl');

    final isStarred = ref.read(isStarredProvider);

    Uri uri = Uri.https(baseUrl, 'v1/entries', {
      'order': orderBy.value,
      'direction': direction.value,
      if (starredOffset > 0) 'offset': '$starredOffset',
      if (isStarred == true) 'starred': '$isStarred',
    });

    log("Book: $uri");

    try {
      final res = await getHttpResp(uri, userPassEncoded);

      Map<String, dynamic> decodedData = jsonDecode(res.body);

      final List<News> fetchedNewsList = [];

      for (var i = 0; i < decodedData['entries'].length; i++) {
        // log('${i} -> ${decodedData['entries'][i]['title']}');
        final info = decodedData['entries'][i];

        String imageUrl = getImageUrl(info);

        DateTime dateTime = getDateTime(info);

        String titleTextDecoded = utf8.decode(info['title'].runes.toList());

        Status status =
            info['status'] == 'unread' ? Status.unread : Status.read;

        final createdNews = News(
          entryId: info['id'],
          feedId: info['feed_id'],
          categoryTitle: info['feed']['category']['title'],
          titleText: titleTextDecoded,
          author: info['author'],
          readTime: info['reading_time'],
          isFav: info['starred'],
          link: info['url'],
          content: info['content'],
          imageUrl: imageUrl,
          status: status,
          publishedTime: dateTime,
        );

        fetchedNewsList.add(createdNews);
      }
      state = fetchedNewsList;
    } on TimeoutException catch (e) {
      log('Timeout Error: $e');
      return showErrorDialogue(context, ref, ErrorString.requestTimeout.value);
    } on SocketException catch (e) {
      log('Socket Error: $e');
      return showErrorDialogue(context, ref, ErrorString.socket.value);
    } catch (e) {
      log('General Error: $e');
      return showErrorDialogue(
          context, ref, ErrorString.somethingWrongAdmin.value);
    }
  }

  void toggleFavStatus(
    int newsId,
    BuildContext context,
  ) async {
    try {
      state = [
        for (final news in state)
          if (news.entryId == newsId)
            news.copyWith(isFav: !news.isFav)
          else
            news,
      ];

      // Online
      Uri uri = Uri.https(baseUrl, 'v1/entries/$newsId/bookmark');

      final res = await putHttpResp(
        url: null,
        uri: uri,
        bodyMap: null,
        userPassEncoded: userPassEncoded,
      );

      log('${res.statusCode}');
    } on TimeoutException catch (e) {
      log('Timeout Error: $e');
      return showErrorDialogue(context, ref, ErrorString.requestTimeout.value);
    } on SocketException catch (e) {
      log('Socket Error: $e');
      return showErrorDialogue(context, ref, ErrorString.socket.value);
    } on Error catch (e) {
      log('General Error HFR: $e');
      return showErrorDialogue(
          context, ref, ErrorString.somethingWrongAdmin.value);
    } catch (e) {
      log('All other Errors: $e');
      return showErrorDialogue(
          context, ref, ErrorString.somethingWrongAdmin.value);
    }
  }

  void toggleRead(
    int newsId,
    Status stat,
    BuildContext context,
  ) async {
    try {
      state = [
        for (final news in state)
          if (news.entryId == newsId) news.copyWith(status: stat) else news,
      ];

      // Online
      final res = await putHttpResp(
        url: 'https://$baseUrl/v1/entries',
        uri: null,
        bodyMap: {
          "entry_ids": [newsId],
          "status": 'unread',
        },
        userPassEncoded: userPassEncoded,
      );

      log('${res.statusCode}');
    } on TimeoutException catch (e) {
      log('Timeout Error: $e');
      return showErrorDialogue(context, ref, ErrorString.requestTimeout.value);
    } on SocketException catch (e) {
      log('Socket Error: $e');
      return showErrorDialogue(context, ref, ErrorString.socket.value);
    } on Error catch (e) {
      log('General Error HFR: $e');
      return showErrorDialogue(
          context, ref, ErrorString.somethingWrongAdmin.value);
    } catch (e) {
      log('All other Errors: $e');
      return showErrorDialogue(
          context, ref, ErrorString.somethingWrongAdmin.value);
    }
  }
}
