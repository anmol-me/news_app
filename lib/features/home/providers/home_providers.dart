import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/features/home/repository/home_feed_repo.dart';

import '../../../common/enums.dart';
import '../../starred/starred_screen.dart';

final homeOffsetProvider = StateProvider((ref) => 0);

final homeSortDirectionProvider = StateProvider<Sort>((ref) => Sort.descending);

final homeOrderProvider = StateProvider<OrderBy>((ref) => OrderBy.publishedAt);

final homeIsShowReadProvider = StateProvider<bool>((ref) => false);

final homeIsLoadingBookmarkProvider = StateProvider<bool>((ref) => false);
final isStarredProvider = StateProvider<bool>((ref) => false);

final homePageLoadingProvider = StateProvider<bool>((ref) => false);

// final homeIsSelectedProvider =
//     StateProvider<List<bool>>((ref) => [true, false, false]);

final homeMaxPagesProvider = FutureProvider((ref) {
  final totalPages = ref.watch(homeFeedProvider.notifier).totalPage();
  return totalPages;
});

final homeCurrentPageProvider = StateProvider((ref) => 1);

final homeIsNextProvider = StateProvider(
  (ref) {
    final maxPages = ref.watch(homeMaxPagesProvider).value;
    // final newsNotifier = ref.watch(homeFeedProvider);
    // final offset = ref.watch(homeOffsetProvider);

    // final currTotalPage = ((newsNotifier.length + offset) / 100).ceil().toInt();
    // log('MAX: $max, CURR: $curr');

    final currentPage = ref.watch(homeCurrentPageProvider);

    // final currentPage = 1 + homePageHandler;

    if (maxPages == currentPage) {
      return false;
    } else {
      return true;
    }
  },
);

void refreshHomeProviders(ProviderRef ref) {
  ref.refresh(homeOffsetProvider.notifier).update((state) => 0);
  ref.refresh(homeSortDirectionProvider).value;
  ref.refresh(isStarredProvider.notifier).update((state) => false);
  ref.refresh(homeIsShowReadProvider.notifier).update((state) => false);
}

// final sortProvider = StateProvider<bool>((ref) => false);
//
// final sortingProvider = StateProvider<String>((ref) {
//   bool sortType = ref.watch(sortProvider);
//   if (sortType) {
//     log('asc');
//     return 'asc';
//   } else {
//     log('desc');
//     return 'desc';
//   }
// });

//

// final isListEmptyProvider = StateProvider((ref) => false);

// final fetchNewsFuture = FutureProvider((ref) {
//   final newsNotifier = ref.read(newsNotifierProvider.notifier);
//   log('FUTURE PROVIDER');
//   return newsNotifier.fetchEntries();
// });
