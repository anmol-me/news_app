import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common_methods.dart';
import '../../../common_widgets/common_widgets.dart';
import '../../../common/enums.dart';
import '../../../common/api_methods.dart';
import '../../../common/error.dart';
import '../../../models/news.dart';
import '../../authentication/repository/user_preferences.dart';
import '../../details/components/methods.dart';
import '../screens/category_screen.dart';

/// Providers
final catOffsetProvider = StateProvider<int>((ref) => 0);
final isCatLoadingProvider = StateProvider<bool>((ref) => false);

final categoryNotifierProvider =
    NotifierProvider<CategoryNotifier, List<News>>(CategoryNotifier.new);

/// Notifier Class
class CategoryNotifier extends Notifier<List<News>> {
  late UserPreferences userPrefs;
  late StateController<bool> isCatLoadingController;

  @override
  List<News> build() {
    userPrefs = ref.watch(userPrefsProvider);
    isCatLoadingController = ref.watch(isCatLoadingProvider.notifier);
    return [];
  }

  void clearCategoryState() => state.clear();

  Future<void> fetchCategoryEntries(
    int id,
    BuildContext context,
  ) async {
    final mounted = context.mounted;
    final userPassEncoded = userPrefs.getAuthData()!;
    final baseUrl = userPrefs.getUrlData()!;

    final catOffset = ref.read(catOffsetProvider);
    final catSort = ref.read(catSortProvider);
    final isShowReadCat = ref.read(isShowReadCatProvider);

    Uri uri = Uri.https(baseUrl, 'v1/categories/$id/entries', {
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

        final contentFormatted = getContent(info['content']);

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

        fetchedCategoryList.add(createdNews);
      }
      state = fetchedCategoryList;
    } on SocketException catch (_) {
      if (mounted) {
        showErrorSnackBar(
            context: context, text: ErrorString.checkInternet.value);
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        showErrorSnackBar(
            context: context, text: ErrorString.requestTimeout.value);
      }
    } on ServerErrorException catch (e) {
      if (mounted) {
        showErrorSnackBar(context: context, text: '$e');
      }
    } catch (_) {
      if (mounted) {
        showErrorSnackBar(
            context: context, text: ErrorString.generalError.value);
      }
    }
  }

  Future<void> fetchDemoCategoryEntries(
    int id,
    BuildContext context,
  ) async {
    clearCategoryState();

    try {
      String data = await DefaultAssetBundle.of(context).loadString(
        'assets/demo_files/entries.json',
      );

      Map<String, dynamic> decodedData = jsonDecode(data);

      final List<News> fetchedNewsList = [];

      for (var i = 0; i < decodedData['entries'].length; i++) {
        final info = decodedData['entries'][i];

        if (info['feed']['category']['id'] == id) {
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

      state = fetchedNewsList.reversed.toList();
    } catch (_) {
      if (context.mounted) {
        showErrorSnackBar(
            context: context, text: ErrorString.somethingWrongAdmin.value);
      }
    }
  }

  Future<int> catTotalPage(int id) async {
    final userPassEncoded = userPrefs.getAuthData()!;
    final baseUrl = userPrefs.getUrlData()!;

    Uri uri = Uri.https(baseUrl, 'v1/categories/$id/entries', {
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
    final isDemoPref = ref.read(userPrefsProvider).getIsDemo() ?? false;

    final catSort = ref.read(catSortProvider);
    final catSortController = ref.read(catSortProvider.notifier);

    if (catSort == Sort.ascending) {
      catSortController.update((state) => state = Sort.descending);
    } else if (catSort == Sort.descending) {
      catSortController.update((state) => state = Sort.ascending);
    }

    if (!isDemoPref) {
      isCatLoadingController.update((state) => true);
      ref.refresh(catOffsetProvider.notifier).update((state) => 0);

      Future.delayed(const Duration(seconds: 0)).then((_) {
        ref
            .refresh(categoryNotifierProvider.notifier)
            .fetchCategoryEntries(catId, context)
            .then(
              (_) => isCatLoadingController.update((state) => false),
            );
        return null;
      });
    } else {
      // Demo

      if (catSort == Sort.descending) {
        state.sort((a, b) => a.publishedTime.compareTo(b.publishedTime));
      } else {
        state.sort((a, b) => b.publishedTime.compareTo(a.publishedTime));
      }
    }
  }

  void readCatFunction(
    int catId,
    BuildContext context,
  ) {
    final isDemoPref = ref.read(userPrefsProvider).getIsDemo() ?? false;

    final isShowReadCatController = ref.read(isShowReadCatProvider.notifier);
    isShowReadCatController.update((state) => state = !state);

    if (!isDemoPref) {
      isCatLoadingController.update((state) => true);

      ref
          .read(categoryNotifierProvider.notifier)
          .fetchCategoryEntries(catId, context)
          .then(
            (_) => isCatLoadingController.update((state) => false),
          );
    } else {
      // Demo
      final isShowReadCat = ref.read(isShowReadCatProvider);

      if (isShowReadCat) {
        state = state.where((e) => e.status == Status.read).toList();
      } else {
        fetchDemoCategoryEntries(catId, context);
      }
    }
  }

  void toggleFavStatus(
    int newsId,
    BuildContext context,
  ) async {
    final mounted = context.mounted;

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
      if (mounted) {
        showErrorSnackBar(
            context: context, text: ErrorString.checkInternet.value);
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        showErrorSnackBar(
            context: context, text: ErrorString.requestTimeout.value);
      }
    } on ServerErrorException catch (e) {
      if (mounted) {
        showErrorSnackBar(context: context, text: '$e');
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(
            context: context, text: ErrorString.generalError.value);
      }
    }
  }

  void toggleRead(
    int newsId,
    Status stat,
    BuildContext context,
  ) async {
    final mounted = context.mounted;
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
      if (mounted) {
        showErrorSnackBar(
            context: context, text: ErrorString.checkInternet.value);
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        showErrorSnackBar(
            context: context, text: ErrorString.requestTimeout.value);
      }
    } on ServerErrorException catch (e) {
      if (mounted) {
        showErrorSnackBar(context: context, text: '$e');
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(
            context: context, text: ErrorString.generalError.value);
      }
    }
  }

  void clearOrRefreshDemo(
    int catId,
    BuildContext context,
  ) {
    if (state.isNotEmpty) {
      state = [];
    } else {
      ref
          .refresh(categoryNotifierProvider.notifier)
          .fetchDemoCategoryEntries(catId, context);
    }
  }
}
