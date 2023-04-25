import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common_widgets.dart';
import '../../../common/enums.dart';
import '../../../common/backend_methods.dart';
import '../../../common/error.dart';
import '../../../models/news.dart';
import '../../authentication/repository/user_preferences.dart';
import '../screens/category_screen.dart';

/// Providers
final catOffsetProvider = StateProvider<int>((ref) => 0);
final isCatLoadingProvider = StateProvider<bool>((ref) => false);

final categoryNotifierProvider =
    NotifierProvider<CategoryNotifier, List<News>>(CategoryNotifier.new);

/// Notifier Class
class CategoryNotifier extends Notifier<List<News>> {
  late String url;
  late String userPassEncoded;
  late Sort catSort;
  late StateController<bool> isCatLoadingController;

  @override
  List<News> build() {
    url = ref.watch(userPrefsProvider).getUrlData() ?? '';
    userPassEncoded = ref.watch(userPrefsProvider).getAuthData() ?? '';
    catSort = ref.watch(catSortProvider);
    isCatLoadingController = ref.watch(isCatLoadingProvider.notifier);
    return [];
  }

  Future<void> fetchCategoryEntries(
    int id,
    BuildContext context,
  ) async {
    final catOffset = ref.read(catOffsetProvider);
    final isShowReadCat = ref.read(isShowReadCatProvider);

    Uri uri = Uri.https(url, 'v1/categories/$id/entries', {
      'order': 'published_at',
      'direction': catSort.value,
      if (catOffset > 0) 'offset': '$catOffset',
      if (isShowReadCat == true) 'status': 'read',
    });

    try {
      final res = await getHttpResp(uri, userPassEncoded);

      if (res.statusCode >= 400 && res.statusCode <= 599) {
        throw ServerErrorException(res);
      }

      Map<String, dynamic> decodedData = jsonDecode(res.body);

      final List<News> fetchedCategoryList = [];

      for (int i = 0; i < decodedData['entries'].length; i++) {
        var info = decodedData['entries'][i];

        String imageUrl = getImageUrl(info);

        DateTime dateTime = getDateTime(info);

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
          content: info['content'],
          imageUrl: imageUrl,
          status: status,
          publishedTime: dateTime,
        );

        fetchedCategoryList.add(createdNews);
      }
      state = fetchedCategoryList;
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

  Future<int> catTotalPage(int id) async {
    Uri uri = Uri.https(url, 'v1/categories/$id/entries', {
      'order': 'published_at',
    });

    try {
      final res = await getHttpResp(uri, userPassEncoded);

      Map<String, dynamic> decodedData = jsonDecode(res.body);

      double numOfHundreds = decodedData['total'] / 100;
      int pages = numOfHundreds.ceil();
      return pages;
    } catch (e) {
      return 1;
    }
  }

  Future<void> refresh(
    int catId,
    BuildContext context,
  ) async {
    isCatLoadingController.update((state) => true);

    ref.refresh(catSortProvider).value;
    ref.refresh(catOffsetProvider.notifier).update((state) => 0);
    ref.refresh(isShowReadCatProvider.notifier).update((state) => false);
    ref
        .refresh(categoryNotifierProvider.notifier)
        .fetchCategoryEntries(catId, context)
        .then(
          (_) => isCatLoadingController.update((state) => false),
        );
  }

  void next(
    int catId,
    BuildContext context,
  ) {
    isCatLoadingController.update((state) => true);

    final catOffsetController = ref.read(catOffsetProvider.notifier);
    catOffsetController.update((state) => state += 100);
    ref
        .read(categoryNotifierProvider.notifier)
        .fetchCategoryEntries(catId, context)
        .then(
      (_) {
        isCatLoadingController.update((state) => false);
      },
    );
  }

  void previous(
    int catId,
    BuildContext context,
  ) {
    isCatLoadingController.update((state) => true);

    final catOffsetController = ref.read(catOffsetProvider.notifier);
    catOffsetController.update((state) => state -= 100);

    ref
        .read(categoryNotifierProvider.notifier)
        .fetchCategoryEntries(catId, context)
        .then(
      (_) {
        isCatLoadingController.update((state) => false);
      },
    );
  }

  void sortCatFunction(
    int catId,
    BuildContext context,
  ) {
    isCatLoadingController.update((state) => true);
    ref.refresh(catOffsetProvider.notifier).update((state) => 0);

    final catSortController = ref.read(catSortProvider.notifier);

    if (catSort == Sort.ascending) {
      catSortController.update((state) => state = Sort.descending);
    } else if (catSort == Sort.descending) {
      catSortController.update((state) => state = Sort.ascending);
    }

    Future.delayed(const Duration(seconds: 0)).then((_) {
      ref
          .refresh(categoryNotifierProvider.notifier)
          .fetchCategoryEntries(catId, context)
          .then(
            (_) => isCatLoadingController.update((state) => false),
          );
      return null;
    });
  }

  void readCatFunction(
    int catId,
    BuildContext context,
  ) {
    isCatLoadingController.update((state) => true);

    final isShowReadCatController = ref.read(isShowReadCatProvider.notifier);
    isShowReadCatController.update((state) => state = !state);

    ref
        .read(categoryNotifierProvider.notifier)
        .fetchCategoryEntries(catId, context)
        .then(
          (_) => isCatLoadingController.update((state) => false),
        );
  }
}
