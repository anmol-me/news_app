import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/features/authentication/repository/auth_repo.dart';

import '../../../common/common_widgets.dart';
import '../../../common/enums.dart';
import '../../../common/error.dart';
import '../../../common/backend_methods.dart';
import '../../../common/frontend_methods.dart';
import '../../../models/news.dart';
import '../providers/home_providers.dart';

class HomeFeedNotifier extends Notifier<List<News>> {
  late UserPreferences userPrefs;
  late String userPassEncoded;
  late Sort direction;
  late int offsetNumber;
  late bool isStarred;
  late bool isRead;
  late OrderBy orderBy;

  @override
  List<News> build() {
    userPrefs = ref.watch(userPrefsProvider);
    userPassEncoded = ref.watch(userPrefsProvider).getAuthData() ?? '';

    orderBy = ref.watch(homeOrderProvider);
    direction = ref.watch(homeSortDirectionProvider);
    offsetNumber = ref.watch(homeOffsetProvider);

    isStarred = ref.watch(isStarredProvider);
    isRead = ref.watch(homeIsShowReadProvider);
    return [];
  }

  Future<void> fetchEntries(BuildContext context) async {
    final url = userPrefs.getUrlData();

    Uri uri = Uri.https(url!, 'v1/entries', {
      'order': orderBy.value,
      'direction': direction.value,
      if (offsetNumber > 0) 'offset': '$offsetNumber',
      if (isRead == true) 'status': 'read',
      if (isStarred == true) 'starred': '$isStarred',
    });

    try {
      final res = await getHttpResp(uri, userPassEncoded);

      if (res.statusCode >= 400 && res.statusCode <= 599) {
        throw ServerErrorException(res);
      }

      Map<String, dynamic> decodedData = jsonDecode(res.body);

      final List<News> fetchedNewsList = [];

      for (var i = 0; i < decodedData['entries'].length; i++) {
        final info = decodedData['entries'][i];

        String imageUrl = getImageUrl(info);

        DateTime dateTime = getDateTime(info);

        String titleTextDecoded = utf8.decode(info['title'].runes.toList());

        Status status =
            info['status'] == 'unread' ? Status.unread : Status.read;

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
          status: status,
          publishedTime: dateTime,
        );

        fetchedNewsList.add(createdNews);
      }
      state = fetchedNewsList;

      /// Todo: On error, goto authScreen
    } on TimeoutException catch (_) {
      showErrorDialogue(context, ref, ErrorString.requestTimeout.value);
    } on SocketException catch (_) {
      showErrorDialogue(context, ref, ErrorString.socket.value);
    } on ServerErrorException catch (e) {
      showErrorDialogue(context, ref, '$e');
    } catch (e) {
      showErrorDialogue(context, ref, ErrorString.somethingWrongAdmin.value);
    }
  }

  Future<void> refreshAll(
    BuildContext context,
  ) async {
    final url = userPrefs.getUrlData();

    try {
      Uri uri = Uri.https(url!, '/v1/feeds/refresh');

      final res = await putHttpResp(
        url: null,
        uri: uri,
        bodyMap: null,
        userPassEncoded: userPassEncoded,
      );

      if (res.statusCode >= 400 && res.statusCode <= 599) {
        throw ServerErrorException(res);
      }
    } on SocketException catch (_) {
      showErrorSnackBar(
          context: context, text: ErrorString.checkInternet.value);
    } on TimeoutException catch (_) {
      showErrorSnackBar(
          context: context, text: ErrorString.requestTimeout.value);
    } on ServerErrorException catch (e) {
      showErrorSnackBar(context: context, text: '$e');
    } catch (e) {
      showErrorSnackBar(context: context, text: ErrorString.generalError.value);
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

      if (res.statusCode >= 400 && res.statusCode <= 599) {
        throw ServerErrorException(res);
      }
    } on SocketException catch (_) {
      showErrorSnackBar(
          context: context, text: ErrorString.checkInternet.value);
    } on TimeoutException catch (_) {
      showErrorSnackBar(
          context: context, text: ErrorString.requestTimeout.value);
    } on ServerErrorException catch (e) {
      showErrorSnackBar(context: context, text: '$e');
    } catch (e) {
      showErrorSnackBar(context: context, text: ErrorString.generalError.value);
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
          "status": stat.value,
        },
        userPassEncoded: userPassEncoded,
      );

      if (res.statusCode >= 400 && res.statusCode <= 599) {
        throw ServerErrorException(res);
      }
    } on SocketException catch (_) {
      showErrorSnackBar(
          context: context, text: ErrorString.checkInternet.value);
    } on TimeoutException catch (_) {
      showErrorSnackBar(
          context: context, text: ErrorString.requestTimeout.value);
    } on ServerErrorException catch (e) {
      showErrorSnackBar(context: context, text: '$e');
    } catch (e) {
      showErrorSnackBar(context: context, text: ErrorString.generalError.value);
    }
  }

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

      if (res.statusCode >= 400 && res.statusCode <= 599) {
        return 1;
      }

      Map<String, dynamic> decodedData = jsonDecode(res.body);

      double numOfHundreds = decodedData['total'] / 100;
      int pages = numOfHundreds.ceil();
      return pages;
    } catch (e) {
      return 1;
    }
  }
}
