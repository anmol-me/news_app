import 'dart:convert';
import 'dart:developer' show log;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/features/authentication/repository/auth_repo.dart';

import '../../../common/enums.dart';
import '../../../common/backend_methods.dart';
import '../../../models/news.dart';
import '../../home/repository/home_feed_repo.dart';
import '../screens/category_screen.dart';

final catOffsetProvider = StateProvider<int>((ref) => 0);

final isCatLoadingProvider = StateProvider<bool>((ref) => false);

final isCatAscProvider = StateProvider<bool>((ref) => false);

final menuProvider = StateProvider<DropItems>((ref) => DropItems.refresh);

// final isNextCatProvider = StateProvider<bool>((ref) => false);

final categoryNotifierProvider =
    NotifierProvider<CategoryNotifier, List<News>>(CategoryNotifier.new);

class CategoryNotifier extends Notifier<List<News>> {
  late String url;
  late String userPassEncoded;

  @override
  List<News> build() {
    url = ref.watch(userPrefsProvider).getUrlData() ?? '';
    userPassEncoded = ref.watch(userPrefsProvider).getAuthData() ?? '';
    return [];
  }

  /// Fetch --------------------------------------------------------------------------------
  Future<void> fetchCategoryEntries(
    int id,
    Sort sort,
    // int catOffset,
  ) async {
    final catOffset = ref.read(catOffsetProvider);
    final isShowReadCat = ref.read(isShowReadCatProvider);

    log('CAT-ID: $id');
    log('CHECK SORT: ${sort.value}');
    log('CHECK READ: $isShowReadCat');

    Uri uri = Uri.https(url, 'v1/categories/$id/entries', {
      'order': 'published_at',
      'direction': sort.value,
      if (catOffset > 0) 'offset': '$catOffset',
      if (isShowReadCat == true) 'status': 'unread',
    });

    log('$uri');

    try {
      final res = await getHttpResp(uri, userPassEncoded);

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
    } catch (e) {
      log('CATEGORY: $e');
    }
  }

  /// catTotalPage --------------------------------------------------------------------------------
  Future<int> catTotalPage(int id) async {
    Uri uri = Uri.https(url, 'v1/categories/$id/entries', {
      'order': 'published_at',
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
}
