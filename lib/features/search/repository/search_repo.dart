import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/common/enums.dart';
import 'package:news_app/features/app_bar/app_drawer.dart';

import '../../../common/common_methods.dart';
import '../../../common_widgets/common_widgets.dart';
import '../../../common/api_methods.dart';
import '../../../common/error.dart';
import '../../../models/news.dart';
import '../../authentication/repository/user_preferences.dart';
import '../../details/components/methods.dart';
import '../../home/providers/home_providers.dart';
import '../screens/search_screen.dart';

/// Providers
final searchNotifierProvider =
    AutoDisposeNotifierProvider<SearchNotifier, List<News>>(
  SearchNotifier.new,
);

/// Search Notifier
class SearchNotifier extends AutoDisposeNotifier<List<News>> {
  late UserPreferences userPrefs;
  late Sort direction;
  late int offsetNumber;
  late bool isStarred;
  late bool isRead;

  @override
  List<News> build() {
    userPrefs = ref.watch(userPrefsProvider);

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
    try {
      final userPassEncoded = userPrefs.getAuthData()!;
      final baseUrl = userPrefs.getUrlData()!;

      Uri uri = Uri.https(baseUrl, 'v1/entries', {
        'order': 'published_at',
        'search': searchText,
      });

      final res = await getHttpResp(uri, userPassEncoded);

      if (res.statusCode >= 400 && res.statusCode <= 599) {
        throw ServerErrorException(res);
      }

      Map<String, dynamic> decodedData = jsonDecode(res.body);

      if (res.statusCode == 200) {
        final List<News> fetchedNewsList = [];

        for (var i = 0; i < decodedData['entries'].length; i++) {
          var info = decodedData['entries'][i];

          String imageUrl = getImageUrl(info);

          DateTime dateTime = getDateTime(info);

          String titleTextDecoded = utf8.decode(info['title'].runes.toList());
          String categoryTitleTextDecoded =
              utf8.decode(info['feed']['category']['title'].runes.toList());

          final contentFormatted = getContent(info['content']);

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
            status: info['status'] == 'unread' ? Status.unread : Status.read,
            publishedTime: dateTime,
          );

          fetchedNewsList.add(createdNews);
        }

        return state = fetchedNewsList;
      }
      return [];
    } on SocketException catch (_) {
      showErrorSnackBar(
          context: context, text: ErrorString.checkInternet.value);
      return [];
    } on TimeoutException catch (_) {
      showErrorSnackBar(
          context: context, text: ErrorString.requestTimeout.value);
      return [];
    } on ServerErrorException catch (e) {
      showErrorSnackBar(context: context, text: '$e');
      return [];
    } catch (e) {
      showErrorSnackBar(context: context, text: ErrorString.generalError.value);
      return [];
    }
  }

  void toggleFavStatus(
    int newsId,
    BuildContext context,
  ) async {
    try {
      final userPassEncoded = userPrefs.getAuthData()!;

      state = [
        for (final news in state)
          if (news.entryId == newsId)
            news.copyWith(isFav: !news.isFav)
          else
            news,
      ];

      // Online
      final url = userPrefs.getUrlData();
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
      state = [
        for (final news in state)
          if (news.entryId == newsId) news.copyWith(status: stat) else news,
      ];

      // Online
      final userPassEncoded = userPrefs.getAuthData()!;
      final baseUrl = userPrefs.getUrlData()!;

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

  void searchFunction(
    TextEditingController searchTextController,
    GlobalKey<FormState> formKey,
    BuildContext context,
  ) {
    final isValid = formKey.currentState!.validate();

    if (!isValid) return;

    ref.read(showFirstSearchProvider.notifier).update((state) => false);

    FocusManager.instance.primaryFocus?.unfocus();

    final showNoResultsController = ref.read(showNoResultsProvider.notifier);

    final isDemoPref = ref.read(userPrefsProvider).getIsDemo() ?? false;
    if (isDemoPref) {
      ref
          .read(searchNotifierProvider.notifier)
          .fetchDemoSearchResults(
            searchTextController.text,
            context,
          )
          .then((value) {
        if (value.isEmpty) {
          showNoResultsController.update((state) => true);
        } else {
          showNoResultsController.update((state) => false);
        }
      });

      return;
    }

    final showSearchLoaderController =
        ref.read(showSearchLoaderProvider.notifier);

    showSearchLoaderController.update((state) => true);

    ref
        .read(searchNotifierProvider.notifier)
        .fetchSearchResults(
          context,
          searchTextController.text,
        )
        .then((value) {
      if (value.isEmpty) {
        showNoResultsController.update((state) => true);
      } else {
        showNoResultsController.update((state) => false);
      }

      showSearchLoaderController.update((state) => false);
    });
  }

  /// Demo
  Future<List<News>> fetchDemoSearchResults(
    String searchText,
    BuildContext context,
  ) async {
    String data = await DefaultAssetBundle.of(context).loadString(
      'assets/demo_files/entries.json',
    );

    Map<String, dynamic> decodedData = jsonDecode(data);

    final List<News> fetchedNewsList = [];

    for (var i = 0; i < decodedData['entries'].length; i++) {
      final info = decodedData['entries'][i];
      final titleText = info['title'].toString();

      if (titleText.containsIgnoreCase(searchText)) {
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
    }
    return state = fetchedNewsList.reversed.toList();
  }
}

extension SearchString on String {
  bool containsIgnoreCase(String secondString) {
    return toLowerCase().contains(secondString.toLowerCase());
  }
}
