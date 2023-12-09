import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common_methods.dart';
import '../../../common_widgets/common_widgets.dart';
import '../../../common/enums.dart';
import '../../../common/error.dart';
import '../../../common/api_methods.dart';
import '../../../common/frontend_methods.dart';
import '../../../models/news.dart';
import '../../authentication/repository/auth_repo.dart';
import '../../authentication/repository/user_preferences.dart';
import '../../details/components/methods.dart';
import '../providers/home_providers.dart';

class HomeFeedNotifier extends Notifier<List<News>> {
  late UserPreferences userPrefs;
  late int offsetNumber;
  late OrderBy orderBy;

  @override
  List<News> build() {
    userPrefs = ref.watch(userPrefsProvider);
    orderBy = ref.watch(homeOrderProvider);
    offsetNumber = ref.watch(homeOffsetProvider);
    return [];
  }

  void clearHomeState() => state.clear();

  Future<void> fetchEntries(BuildContext context) async {
    clearHomeState();

    final userPassEncoded = userPrefs.getAuthData() ?? '';
    final baseUrl = userPrefs.getUrlData() ?? '';

    final direction = ref.read(homeSortDirectionProvider);
    final isRead = ref.read(homeIsShowReadProvider);
    final isStarred = ref.read(isStarredProvider);

    if (userPassEncoded.isEmpty || baseUrl.isEmpty) {
      debugPrint('EMPTY');
      // ref.read(homePageLoadingProvider.notifier).update((state) => false);
      scheduleMicrotask(() {
        // context.goNamed(AuthScreen.routeNamed);
        ref.read(authRepoProvider).logout(context);
      });
      return;
    }

    Uri uri = Uri.https(baseUrl, 'v1/entries', {
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

        final contentFormatted = getContent(info['content']);

        String titleTextDecoded = utf8.decode(info['title'].runes.toList());
        String categoryTitleTextDecoded =
            utf8.decode(info['feed']['category']['title'].runes.toList());

        Status status =
            info['status'] == 'unread' ? Status.unread : Status.read;

        final createdNews = News(
          entryId: info['id'],
          feedId: info['feed_id'],
          catId: info['feed']['category']['id'],
          categoryTitle: categoryTitleTextDecoded,
          titleText: titleTextDecoded,
          author: info['author'],
          readTime: info['reading_time'],
          isFav: info['starred'],
          link: info['url'],
          content: contentFormatted,
          imageUrl: imageUrl,
          status: status,
          publishedTime: dateTime,
        );

        fetchedNewsList.add(createdNews);
      }
      state = fetchedNewsList;
    } on TimeoutException catch (_) {
      if (context.mounted) {
        showErrorDialogue(context, ref, ErrorString.requestTimeout.value);
      }
    } on SocketException catch (_) {
      if (context.mounted) {
        showErrorDialogue(context, ref, ErrorString.socket.value);
      }
    } on ServerErrorException catch (e) {
      if (context.mounted) {
        showErrorDialogue(context, ref, '$e');
      }
    } catch (_) {
      if (context.mounted) {
        showErrorDialogue(context, ref, ErrorString.somethingWrongAdmin.value);
      }
    }
  }

  Future<void> refreshAll(
    BuildContext context,
  ) async {
    final userPassEncoded = userPrefs.getAuthData()!;
    final baseUrl = userPrefs.getUrlData()!;

    try {
      Uri uri = Uri.https(baseUrl, '/v1/feeds/refresh');

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
    final userPassEncoded = userPrefs.getAuthData()!;
    final baseUrl = userPrefs.getUrlData()!;

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
    final userPassEncoded = userPrefs.getAuthData()!;
    final baseUrl = userPrefs.getUrlData()!;

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
    final userPassEncoded = userPrefs.getAuthData()!;
    final baseUrl = userPrefs.getUrlData()!;

    final direction = ref.read(homeSortDirectionProvider);
    final isRead = ref.read(homeIsShowReadProvider);
    final isStarred = ref.read(isStarredProvider);

    Uri uri = Uri.https(baseUrl, 'v1/entries', {
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

  /// Demo
  Future<void> fetchDemoEntries(BuildContext context) async {
    try {
      String data = await DefaultAssetBundle.of(context).loadString(
        'assets/demo_files/entries.json',
      );

      Map<String, dynamic> decodedData = jsonDecode(data);

      final List<News> fetchedNewsList = [];

      for (var i = 0; i < decodedData['entries'].length; i++) {
        final info = decodedData['entries'][i];

        String imageUrl = getImageUrl(info);

        DateTime dateTime = getDateTime(info);

        final contentFormatted = getContentJson(info['content']);

        Status status =
            info['status'] == 'unread' ? Status.unread : Status.read;

        final createdNews = News(
          entryId: info['id'],
          feedId: info['feed_id'],
          catId: info['feed']['category']['id'],
          categoryTitle: info['feed']['category']['title'],
          titleText: info['title'],
          author: info['author'],
          readTime: info['reading_time'],
          isFav: info['starred'],
          link: info['url'],
          content: contentFormatted,
          imageUrl: imageUrl,
          status: status,
          publishedTime: dateTime,
        );

        fetchedNewsList.add(createdNews);
      }

      state = fetchedNewsList.reversed.toList();
    } catch (_) {
      if (context.mounted) {
        showErrorDialogue(context, ref, ErrorString.somethingWrongAdmin.value);
      }
    }
  }

  void sortDemoEntries() {
    final sortAs = ref.read(homeSortDirectionProvider);
    final sortDirectionController =
        ref.read(homeSortDirectionProvider.notifier);

    if (sortAs == Sort.descending) {
      state.sort((a, b) => a.publishedTime.compareTo(b.publishedTime));
      sortDirectionController.update((state) => state = Sort.ascending);
    } else {
      state.sort((a, b) => b.publishedTime.compareTo(a.publishedTime));
      sortDirectionController.update((state) => state = Sort.descending);
    }
  }

  void readDemoEntries() {
    state = state.where((e) => e.status == Status.read).toList();
  }

  void starredDemoEntries() {
    state = state.where((e) => e.isFav == true).toList();
  }
}
