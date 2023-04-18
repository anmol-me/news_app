import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/common/enums.dart';

import '../../../common/common_widgets.dart';
import '../../../common/backend_methods.dart';
import '../../../common/frontend_methods.dart';
import '../../../models/news.dart';
import '../../authentication/repository/auth_repo.dart';
import '../../home/providers/home_providers.dart';
import '../../starred/starred_screen.dart';

final searchNotifierProvider =
    AutoDisposeNotifierProvider<SearchNotifier, List<News>>(SearchNotifier.new);

/// Search Notifier //////////////////////////////////////////////////////////
class SearchNotifier extends AutoDisposeNotifier<List<News>> {
  late UserPreferences userPrefs;
  late String baseUrl;
  late String userPassEncoded;
  late Sort direction;
  late int offsetNumber;
  late bool isStarred;
  late bool isRead;

  @override
  List<News> build() {
    userPrefs = ref.watch(userPrefsProvider);
    baseUrl = userPrefs.getUrlData()!;
    userPassEncoded = userPrefs.getAuthData()!;

    direction = ref.watch(homeSortDirectionProvider);
    offsetNumber = ref.watch(homeOffsetProvider);

    isStarred = ref.watch(isStarredProvider);
    isRead = ref.watch(homeIsShowReadProvider);

    return [];
  }

  Future<List<News>> fetchSearchResults(
    BuildContext context,
    String searchText,
  ) async {
    checkAuth(context, userPassEncoded, baseUrl, userPrefs);

    try {
      Uri uri = Uri.https(baseUrl, 'v1/entries', {
        'order': 'published_at',
        'search': searchText,
      });

      final res = await getHttpResp(uri, userPassEncoded);

      Map<String, dynamic> decodedData = jsonDecode(res.body);

      log('CODE: ${res.statusCode}');

      if (res.statusCode == 200) {
        final List<News> fetchedNewsList = [];

        for (var i = 0; i < decodedData['entries'].length; i++) {
          // log(decodedData['entries'][i]['title'].toString());
          var info = decodedData['entries'][i];

          String imageUrl = getImageUrl(info);

          DateTime dateTime = getDateTime(info);

          String titleTextDecoded = utf8.decode(info['title'].runes.toList());

          final createdNews = News(
            entryId: info['id'],
            feedId: info['feed_id'],
            catId: info['feed']['category']['id'],
            categoryTitle: info['feed']['category']['title'],
            titleText: titleTextDecoded,
            author: info['author'],
            readTime: info['reading_time'],
            isFav: info['starred'],
            link: info['url'],
            content: info['content'],
            imageUrl: imageUrl,
            status: info['status'] == 'unread' ? Status.unread : Status.read,
            publishedTime: dateTime,
          );

          fetchedNewsList.add(createdNews);
        }

        return state = fetchedNewsList;
      } else {
        if (context.mounted) {
          showSnackBar(context: context, text: 'Status: ${res.statusCode}');
        }
        log('Not LOGIN: ${res.statusCode}');
        return [];
      }
    } on TimeoutException catch (e) {
      log('Timeout Error: $e');
      showErrorDialogue(context, ref, ErrorString.requestTimeout.value);
      return [];
    } on SocketException catch (e) {
      log('Socket Error: $e');
      showErrorDialogue(context, ref, ErrorString.socket.value);
      return [];
    } on Error catch (e) {
      log('General Error: $e');
      showErrorDialogue(context, ref, ErrorString.somethingWrongAdmin.value);
      return [];
    } catch (e) {
      log('All other Errors: $e');
      showErrorDialogue(context, ref, ErrorString.somethingWrongAdmin.value);
      return [];
    }
  }
}
