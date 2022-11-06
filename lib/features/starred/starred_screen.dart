import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/features/starred/starred_repo.dart';

import '../../common/constants.dart';
import '../../common/enums.dart';
import '../app_bar/app_drawer.dart';
import '../home/providers/home_providers.dart';
import '../home/repository/home_feed_repo.dart';
import '../home/screens/home_feed_screen.dart';
import '../search/screens/search_screen.dart';

/// Providers
final isLoadingStarredProvider = StateProvider<bool>((ref) => false);
final isShowReadStarredProvider = StateProvider<bool>((ref) => false);
final isStarredProvider = StateProvider<bool>((ref) => false);

final sortAsStarredProvider = StateProvider<Sort>((ref) => Sort.descending);

final starredOffsetProvider = StateProvider<int>((ref) => 0);
final starredPageHandlerProvider = StateProvider<int>((ref) => 0);

final starredIsNextProvider = StateProvider(
  (ref) {
    final maxPages = ref.watch(homeMaxPagesProvider).value;

    final homePageHandler = ref.watch(starredPageHandlerProvider);

    final currentPage = 1 + homePageHandler;

    if (maxPages == currentPage) {
      return false;
    } else {
      return true;
    }
  },
);

/// Widgets
class StarredScreen extends HookConsumerWidget {
  static const routeNamed = '/starred-screen';

  const StarredScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Providers ///
    final isLoadingStarred = ref.watch(isLoadingStarredProvider);
    final isLoadingStarredController =
        ref.watch(isLoadingStarredProvider.notifier);

    final isStarred = ref.watch(isStarredProvider);
    final isStarredController = ref.watch(isStarredProvider.notifier);

    final isShowReadStarred = ref.watch(isShowReadStarredProvider);

    final starredSortAs = ref.watch(sortAsStarredProvider);

    final canGoToNextPage = ref.watch(starredIsNextProvider);
    final canGoToPreviousPage = ref.watch(starredOffsetProvider) != 0;

    // final newsNotifier = ref.watch(homeFeedProvider);
    // final newsNotifierController = ref.watch(homeFeedProvider.notifier);

    final newsNotifier = ref.watch(starredNotifierProvider);
    final newsNotifierController = ref.watch(starredNotifierProvider.notifier);

    useEffect(
      () {
        //
        final isLoadingStarredController =
            ref.read(isLoadingStarredProvider.notifier);

        Future.delayed(Duration.zero).then(
          (_) => isLoadingStarredController.update((state) => true),
        );

        ref
            .read(starredNotifierProvider.notifier)
            .fetchStarredEntries(context)
            .then(
              (_) => isLoadingStarredController.update((state) => false),
            );
        //
        return null;
      },
      [],
    );

    /// Functions ///

    /// Previous
    void previousFunction() {
      isLoadingStarredController.update((state) => true);

      ref.read(starredPageHandlerProvider.notifier).update(
            (state) => state != 1 ? state -= 1 : 0,
          );

      ref.read(starredOffsetProvider.notifier).update((state) => state -= 100);
      // log('PREVIOUS-OFFSET: ${ref.watch(offsetProvider)}');

      ref.read(homeFeedProvider.notifier).fetchEntries(context).then(
            (_) => isLoadingStarredController.update((state) => false),
          );
    }

    /// Next
    void nextFunction() {
      isLoadingStarredController.update((state) => true);

      ref
          .read(starredPageHandlerProvider.notifier)
          .update((state) => state += 1);

      ref.read(starredOffsetProvider.notifier).update((state) => state += 100);

      ref.read(homeFeedProvider.notifier).fetchEntries(context).then(
        (_) {
          // log(newsNotifier.length.toString());
          isLoadingStarredController.update((state) => false);
        },
      );
    }

    Future<void> refreshStarred(
      NavigatorState navigator,
      StateController<bool> isLoadingStarredController,
    ) async {
      isLoadingStarredController.update((state) => true);
      ref
          .refresh(starredNotifierProvider.notifier)
          .fetchStarredEntries(context)
          .then(
            (_) => isLoadingStarredController.update((state) => false),
          );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(SearchScreen.routeNamed);
            },
            icon: const Icon(Icons.search),
          ),
          buildPopupMenuButton(
            ref: ref,
            isShowRead: isShowReadStarred,
            sort: starredSortAs,
            sortFunction: () {},
            read: () {},
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Top Column
          buildTopColumn(
            isLoadingStarred,
            canGoToPreviousPage,
            previousFunction,
            canGoToNextPage,
            nextFunction,
          ),
          if (isLoadingStarred)
            // const LinearLoader()
            const Text('Loading...')
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => refreshStarred(
                  Navigator.of(context),
                  isLoadingStarredController,
                ),
                color: colorRed,
                child: Scrollbar(
                  child: newsNotifier.isEmpty && isStarred
                      ? const Text('No Favourites')
                      : newsNotifier.isEmpty
                          ? const Text('List is Empty')
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: newsNotifier.length,
                              itemBuilder: (context, index) {
                                final newsItem = newsNotifier[index];
                                // final dateTime = getDate(newsItem);

                                // return buildExpansionWidget(
                                //   newsItem,
                                //   dateTime,
                                //   context,
                                //   newsNotifierController,
                                // );

                                return BuildExpansionWidget(
                                  newsItem: newsItem,
                                );
                              }),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
