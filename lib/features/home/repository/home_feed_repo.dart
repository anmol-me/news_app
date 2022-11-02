import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:intl/intl.dart';
import 'package:news_app/features/authentication/repository/auth_repo.dart';

import '../../../common/enums.dart';
import '../../../common/backend_methods.dart';
import '../../../common/frontend_methods.dart';
import '../../../models/news.dart';
import '../providers/home_providers.dart';

/// Providers -----------------------------------------------------------------------------

final homeFeedProvider =
    StateNotifierProvider<HomeFeedNotifier, List<News>>((ref) {
  final userPrefs = ref.watch(userPrefsProvider);
  final userPassEncoded = ref.watch(userPrefsProvider).getAuthData();

  var orderBy = ref.watch(homeOrderProvider);
  final direction = ref.watch(homeSortDirectionProvider);
  var offsetNumber = ref.watch(homeOffsetProvider);

  final isStarred = ref.watch(homeIsStarredProvider);
  final isRead = ref.watch(homeIsShowReadProvider);

  return HomeFeedNotifier(
    ref,
    userPrefs,
    userPassEncoded!,
    direction,
    offsetNumber,
    isStarred,
    isRead,
    orderBy,
  );
});

/// Method -------------------------------------------------------------------------------
class HomeFeedNotifier extends StateNotifier<List<News>> {
  final StateNotifierProviderRef ref;
  final UserPreferences userPrefs;
  final String userPassEncoded;
  final Sort direction;
  final int offsetNumber;
  final bool isStarred;
  final bool isRead;
  final OrderBy orderBy;

  HomeFeedNotifier(
    this.ref,
    this.userPrefs,
    this.userPassEncoded,
    this.direction,
    this.offsetNumber,
    this.isStarred,
    this.isRead,
    this.orderBy,
  ) : super([]);

  /// Fetch all Feeds
  Future<void> fetchEntries(BuildContext context) async {
    final url = userPrefs.getUrlData();

    log('Fetching thro $url');

    Uri uri = Uri.https(url!, 'v1/entries', {
      'order': orderBy.value,
      'direction': direction.value,
      if (offsetNumber > 0) 'offset': '$offsetNumber',
      if (isRead == true) 'status': 'read',
      if (isStarred == true) 'starred': '$isStarred',
    });

    log("$uri");

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
    final url = userPrefs.getUrlData();

    try {
      state = [
        for (final news in state)
          if (news.entryId == newsId)
            news.copyWith(isFav: !news.isFav)
          else
            news,
      ];

      // Online
      Uri uri = Uri.https(url!, 'v1/entries/$newsId/bookmark');

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
      final url = userPrefs.getUrlData();

      state = [
        for (final news in state)
          if (news.entryId == newsId) news.copyWith(status: stat) else news,
      ];

      // Online
      final res = await putHttpResp(
        url: 'https://$url/v1/entries',
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

  // TODO: Called by Category
  Future<Map<String, dynamic>> viewEntryDetails(
    int feedId,
    int entryId,
  ) async {
    final res = await getHttpResp(
      'https://read.rusi.me/v1/feeds/$feedId/entries/$entryId',
      userPassEncoded,
    );

    Map<String, dynamic> decodedData = jsonDecode(res.body);

    log('${feedId}');
    log('${res.statusCode}');
    log(decodedData.toString());
    return decodedData;
  }

  // Future<int> getCount() async {
  //   http.Response res = await http.get(
  //     Uri.parse(
  //         'https://read.rusi.me/v1/entries?&order=published_at&direction=asc'),
  //     headers: {
  //       'Content-Type': 'application/json; charset=UTF-8',
  //       // 'X-Auth-Token': '-5YfpcHn8F__jMhC0MFA-AaMrqLl5ehBaesPuvjCOzg=',
  //       'authorization': userPassEncoded,
  //     },
  //   );
  //
  //   Map<String, dynamic> decodedData = jsonDecode(res.body);
  //
  //   // log('TOTAL COUNT: ${decodedData['total']}');
  //   return decodedData['total'];
  // }

  Future<int> totalPage() async {
    final url = userPrefs.getUrlData();

    Uri uri = Uri.https(url!, 'v1/entries', {
      'order': 'published_at',
      'direction': direction.value,
      'offset': '$offsetNumber',
      if (isRead == true) 'status': 'read',
      if (isStarred == true) 'starred': '$isStarred',
    });

    try {
      final res = await getHttpResp(uri, userPassEncoded);

      Map<String, dynamic> decodedData = jsonDecode(res.body);

      double numOfHundreds = decodedData['total'] / 100;
      int pages = numOfHundreds.ceil();
      log('TOTAL PAGES: $pages');
      return pages;
    } catch (e) {
      return 1;
    }
  }

////////////////////////////////////////////////////////////////////////
// Future<bool> enableNext() async {
//   var num = ref.watch(offsetProvider) + 100;
//   // log('enableNext : ${num}');
//
//   Uri url = Uri.parse(
//       'https://read.rusi.me/v1/entries?&order=published_at&direction=desc&offset=$num');
//
//   try {
//     http.Response res = await http.get(
//       url,
//       headers: {
//         'Content-Type': 'application/json; charset=UTF-8',
//         'X-Auth-Token': '-5YfpcHn8F__jMhC0MFA-AaMrqLl5ehBaesPuvjCOzg=',
//       },
//     );
//
//     Map<String, dynamic> decodedData = jsonDecode(res.body);
//
//     // for (var i = 0; i < decodedData['entries'].length; i++) {
//     // }
//
//     log('NUMBER is: ${decodedData['entries'].length > 100}');
//
//     var canGoNext = decodedData['entries'].length > 100;
//     return canGoNext;
//   } catch (e) {
//     rethrow;
//   }
// }

}

// final getCountProvider =
//     FutureProvider((ref) => ref.watch(homeFeedProvider.notifier).getCount());

// final canGoNextFuture = FutureProvider(
//         (ref) => ref.watch(newsNotifierProvider.notifier).enableNext());

/// /// /// Image Load
// final content = info['content'];
//
// String? imageUrl;
// var re = RegExp(r'(?=https)(.*)(?<=jpg)');
// var match = re.firstMatch(content);
// // if (match != null) log(match.group(0)!);
// if (match != null) imageUrl = match.group(0).toString();
//
// if (imageUrl == null) {
//   var re = RegExp(r'(?=https)(.*)(?<=png)');
//   var match = re.firstMatch(content);
//   if (match != null) imageUrl = match.group(0).toString();
// }
//
// if (imageUrl == null) {
//   var re = RegExp(r'(?=https)(.*)(?<=jpeg)');
//   var match = re.firstMatch(content);
//   if (match != null) imageUrl = match.group(0).toString();
// }
//

/// Old unread
// if (ref.read(isShowReadProvider)) {
//   ref.read(isLoadingPageProvider.notifier).update((state) => true);
//   if (!mounted) return;
//   state = [
//     ...fetchedNewsList
//         .where((element) => element.status == 'unread')
//         .toList()
//   ];
//   log('UNREAD LIST');
//   ref.read(isLoadingPageProvider.notifier).update((state) => false);
// } else {
//   if (!mounted) return;
//   log('LIST UPDATED');
//   state = [...fetchedNewsList];
// }

// extension Extract on String {
//   String? extractImage() {
//     if (contains('img')) {
//       return html_parser
//               .parse(this)
//               .getElementsByTagName('img')[0]
//               .attributes['src'] ??
//           '';
//     } else {
//       return '';
//     }
//   }
// }
