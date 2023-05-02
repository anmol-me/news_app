import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/common/enums.dart';

import '../../../common/common_methods.dart';
import '../../../common_widgets/common_widgets.dart';
import '../../../common/api_methods.dart';
import '../../../common/error.dart';
import '../../../models/news.dart';
import '../../authentication/repository/user_preferences.dart';
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
    try {
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

  void searchFunction(
    TextEditingController searchTextController,
    GlobalKey<FormState> formKey,
    BuildContext context,
  ) {
    final isValid = formKey.currentState!.validate();

    if (!isValid) return;

      final isDemoPref = ref.read(userPrefsProvider).getIsDemo() ?? false;
      if (isDemoPref) {
        showErrorSnackBar(context: context, text: ErrorString.demoSearch.value);
        return;
      }

      FocusManager.instance.primaryFocus?.unfocus();

      final showResultsController = ref.read(showResultsProvider.notifier);

      final showSearchLoaderController =
          ref.read(showSearchLoaderProvider.notifier);

      final searchNotifierController =
          ref.read(searchNotifierProvider.notifier);

      if (searchTextController.text.isEmpty) {
        showResultsController.update((state) => false);
      } else {
        showSearchLoaderController.update((state) => true);

        searchNotifierController
            .fetchSearchResults(
          context,
          searchTextController.text,
        )
            .then((value) {
          if (value.isEmpty) {
            showResultsController.update((state) => false);
          } else {
            showResultsController.update((state) => true);
          }

          showSearchLoaderController.update((state) => false);
        });
      }
  }
}
