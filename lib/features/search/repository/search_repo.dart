import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/common/enums.dart';

import '../../../common/common_widgets.dart';
import '../../../common/backend_methods.dart';
import '../../../common/frontend_methods.dart';
import '../../../models/news.dart';
import '../../../widgets/snack_bar.dart';
import '../../authentication/repository/auth_repo.dart';
import '../../authentication/screens/auth_screen.dart';
import '../../home/providers/home_providers.dart';
import '../../home/repository/home_feed_repo.dart';
import '../../home/screens/home_feed_screen.dart';

// class SearchModel {
//   final String title;
//   final String link;
//   final String discoveryFeedCategory;
//
//   SearchModel({
//     required this.title,
//     required this.link,
//     required this.discoveryFeedCategory,
//   });
// }

final searchNotifierProvider =
    StateNotifierProvider.autoDispose<SearchNotifier, List<News>>((ref) {
  final userPrefs = ref.watch(userPrefsProvider);

  final direction = ref.watch(homeSortDirectionProvider);
  var offsetNumber = ref.watch(homeOffsetProvider);

  final isStarred = ref.watch(homeIsStarredProvider);
  final isRead = ref.watch(homeIsShowReadProvider);

  return SearchNotifier(
    userPrefs,
    direction,
    offsetNumber,
    isStarred,
    isRead,
    ref,
  );
});

/// Search Notifier //////////////////////////////////////////////////////////
class SearchNotifier extends StateNotifier<List<News>> {
  final UserPreferences userPrefs;
  final Sort direction;
  final int offsetNumber;
  final bool isStarred;
  final bool isRead;
  final StateNotifierProviderRef ref;

  SearchNotifier(
    this.userPrefs,
    this.direction,
    this.offsetNumber,
    this.isStarred,
    this.isRead,
    this.ref,
  ) : super([]);

  // List<SearchModel> fetchDiscoveryList() => state;

  Future<List<News>> fetchSearchResults(
    BuildContext context,
    String searchText,
  ) async {
    final userPassEncoded = userPrefs.getAuthData();
    final url = userPrefs.getUrlData();

    checkAuth(context, userPassEncoded);

    try {
      Uri uri = Uri.https(url!, 'v1/entries', {
        'order': 'published_at',
        'search': searchText,
      });

      final res = await getHttpResp(uri, userPassEncoded!);
      Map<String, dynamic> decodedData = jsonDecode(res.body);

      log('CODE: ${res.statusCode}');
      // log('BODY: $responseBody');

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

        log('List: ${fetchedNewsList.length}');
        state = fetchedNewsList;
        log('State: ${state.length}');

        return state = state;
      } else {
        showSnackBar(context: context, text: 'Status: ${res.statusCode}');
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

////////////////////////////////////////////////////////////////////////////////

// List<SearchModel> discoveryFeedList = [
//   SearchModel(
//     title: 'The Verge',
//     link: 'https://www.theverge.com',
//     discoveryFeedCategory: '',
//   ),
// ];

// if (authData == null) {
//   Navigator.of(context).pushNamed(AuthScreen.routeNamed);
//
//   showSnackBar(
//     context: context,
//     content: 'Something went wrong! Please login again',
//   );
// }

// http.Response res = await http.get(
//   uri,
//   headers: {
//     'Content-Type': 'application/json; charset=UTF-8',
//     // 'X-Auth-Token': '-5YfpcHn8F__jMhC0MFA-AaMrqLl5ehBaesPuvjCOzg=',
//     'authorization': authData!,
//   },
// );
