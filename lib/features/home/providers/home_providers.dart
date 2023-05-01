import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/features/home/repository/home_feed_repo.dart';

import '../../../common/enums.dart';
import '../../../models/news.dart';

final homeFeedProvider = NotifierProvider<HomeFeedNotifier, List<News>>(
  HomeFeedNotifier.new,
);

final homeOffsetProvider = StateProvider((ref) => 0);

final homeSortDirectionProvider = StateProvider<Sort>((ref) => Sort.descending);

final homeOrderProvider = StateProvider<OrderBy>((ref) => OrderBy.publishedAt);

final homeIsShowReadProvider = StateProvider<bool>((ref) => false);

final homeIsLoadingBookmarkProvider = StateProvider<bool>((ref) => false);
final isStarredProvider = StateProvider<bool>((ref) => false);

final homePageLoadingProvider = StateProvider<bool>((ref) => false);

final homeMaxPagesProvider = FutureProvider((ref) {
  final totalPages = ref.watch(homeFeedProvider.notifier).totalPage();
  return totalPages;
});

final homeCurrentPageProvider = StateProvider((ref) => 1);

final homeIsNextProvider = StateProvider(
  (ref) {
    final maxPages = ref.watch(homeMaxPagesProvider).value;
    final currentPage = ref.watch(homeCurrentPageProvider);

    if (maxPages == currentPage) {
      return false;
    } else {
      return true;
    }
  },
);
