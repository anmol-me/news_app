import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/common/common_widgets.dart';
import 'package:news_app/features/category/repository/category_repo.dart';
import 'package:news_app/features/app_bar/app_drawer.dart';

import '../../../common/common_methods.dart';
import '../../../common/constants.dart';
import '../../../common/enums.dart';
import '../../../common_widgets/build_popup_menu_button.dart';
import '../../../common_widgets/build_top_bar.dart';
import '../../../components/app_back_button.dart';
import '../../home/providers/home_providers.dart';
import '../../home/screens/home_feed_screen.dart';
import '../../search/screens/search_screen.dart';

/// Providers
final catSortProvider = StateProvider<Sort>((ref) => Sort.descending);

final isShowReadCatProvider = StateProvider<bool>((ref) => false);

final catPageHandlerProvider = StateProvider<int>((ref) => 0);

final catMaxPagesProvider = FutureProvider.family<int, int>((ref, id) {
  final totalPages =
      ref.watch(categoryNotifierProvider.notifier).catTotalPage(id);
  return totalPages;
});

final catIsNextProvider = StateProvider.family<bool, int>(
  (ref, id) {
    final maxPages = ref.watch(catMaxPagesProvider(id)).value;

    final catPageHandler = ref.watch(catPageHandlerProvider);

    final currentPage = 1 + catPageHandler;

    if (maxPages == currentPage) {
      return false;
    } else {
      return true;
    }
  },
);

/// Widgets
class CategoryScreen extends HookConsumerWidget {
  static const routeNamed = '/category-screen';

  final int catId;
  final String catTitle;
  final bool isBackButton;

  const CategoryScreen({
    super.key,
    required this.catId,
    required this.catTitle,
    required this.isBackButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCatLoading = ref.watch(isCatLoadingProvider);
    final isCatLoadingController = ref.watch(isCatLoadingProvider.notifier);

    final catSort = ref.watch(catSortProvider);
    final catSortController = ref.watch(catSortProvider.notifier);

    final isShowReadCat = ref.watch(isShowReadCatProvider);
    final isShowReadCatController = ref.watch(isShowReadCatProvider.notifier);

    useEffect(
      () {
        Future.delayed(Duration.zero)
            .then((_) => isCatLoadingController.update((state) => true));

        ref
            .read(categoryNotifierProvider.notifier)
            .fetchCategoryEntries(catId)
            .then((_) => isCatLoadingController.update((state) => false));

        return null;
      },
      [],
    );

    // For Fav and Read Buttons
    final newsNotifierController = ref.watch(homeFeedProvider.notifier);

    final catNewsNotifier = ref.watch(categoryNotifierProvider);
    final catNewsNotifierController =
        ref.watch(categoryNotifierProvider.notifier);

    // For previous & next buttons
    final catOffset = ref.watch(catOffsetProvider);
    final catOffsetController = ref.watch(catOffsetProvider.notifier);

    final canGoToNextPage = ref.watch(catIsNextProvider(catId));
    final canGoToPreviousPage = ref.watch(catOffsetProvider) != 0;

    // /// Refresh
    // Future<void> refresh() async {
    //   isCatLoadingController.update((state) => true);
    //
    //   ref.refresh(catSortProvider).value;
    //   ref.refresh(catOffsetProvider.notifier).update((state) => 0);
    //   ref.refresh(isShowReadCatProvider.notifier).update((state) => false);
    //   // ref.refresh(homeSortDirectionProvider);
    //
    //   ref
    //       .refresh(categoryNotifierProvider.notifier)
    //       .fetchCategoryEntries(catId, catSort)
    //       .then(
    //         (_) => isCatLoadingController.update((state) => false),
    //       );
    // }

    // /// Next
    // void next() {
    //   isCatLoadingController.update((state) => true);
    //
    //   catOffsetController.update((state) => state += 100);
    //
    //   catNewsNotifierController.fetchCategoryEntries(catId, catSort).then(
    //     (_) {
    //       isCatLoadingController.update((state) => false);
    //     },
    //   );
    // }

    // /// Previous
    // void previous() {
    //   isCatLoadingController.update((state) => true);
    //
    //   catOffsetController.update((state) => state -= 100);
    //
    //   catNewsNotifierController.fetchCategoryEntries(catId, catSort).then(
    //     (_) {
    //       isCatLoadingController.update((state) => false);
    //     },
    //   );
    // }

    // /// Sort
    // void sortCatFunction() {
    //   isCatLoadingController.update((state) => true);
    //   ref.refresh(homeOffsetProvider.notifier).update((state) => 0);
    //   ref.refresh(catOffsetProvider.notifier).update((state) => 0);
    //
    //   if (catSort == Sort.ascending) {
    //     catSortController.update((state) => state = Sort.descending);
    //   } else if (catSort == Sort.descending) {
    //     catSortController.update((state) => state = Sort.ascending);
    //   }
    //   ref
    //       .refresh(categoryNotifierProvider.notifier)
    //       .fetchCategoryEntries(catId, catSort)
    //       .then(
    //         (_) => isCatLoadingController.update((state) => false),
    //       );
    // }

    // /// Show Read
    // void readCatFunction() {
    //   isCatLoadingController.update((state) => true);
    //
    //   isShowReadCatController.update((state) => state = !state);
    //
    //   catNewsNotifierController.fetchCategoryEntries(catId, catSort).then(
    //         (_) => isCatLoadingController.update((state) => false),
    //       );
    // }

    final categoryNotifier = ref.watch(categoryNotifierProvider.notifier);

    final scrollController = ScrollController();

    return Scaffold(
      appBar: isBackButton == true
          ? AppBar(
              title: Text(catTitle),
              leading: const AppBackButton(controller: false),
              actions: [
                IconButton(
                  onPressed: () {
                    context.pushNamed(SearchScreen.routeNamed);

                    // Todo: Nav
                    // Navigator.of(context).pushNamed(SearchScreen.routeNamed);
                  },
                  icon: const Icon(Icons.search),
                ),
                BuildPopupMenuButton(
                  isShowRead: isShowReadCat,
                  sort: catSort,
                  sortFunction: () => categoryNotifier.sortCatFunction(catId),
                  readFunction: () => categoryNotifier.readCatFunction(catId),
                ),
              ],
            )
          : AppBar(
              title: Text(catTitle),
              actions: [
                IconButton(
                  onPressed: () {
                    context.pushNamed(SearchScreen.routeNamed);

                    // Todo: Nav
                    // Navigator.of(context).pushNamed(SearchScreen.routeNamed);
                  },
                  icon: const Icon(Icons.search),
                ),
                BuildPopupMenuButton(
                  isShowRead: isShowReadCat,
                  sort: catSort,
                  sortFunction: () => categoryNotifier.sortCatFunction(catId),
                  readFunction: () => categoryNotifier.readCatFunction(catId),
                ),
              ],
            ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Top Column
          buildTopBar(
            isCatLoading,
            canGoToPreviousPage,
            () => categoryNotifier.previous(catId),
            canGoToNextPage,
            () => categoryNotifier.next(catId),
            ref,
          ),

          // DISPLAY BODY //

          if (isCatLoading || isCatLoading)
            const LinearLoader()
          else if (catNewsNotifier.isEmpty)
            Expanded(child: Center(child: Text(Message.categoryEmpty.value)))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => categoryNotifier.refresh(catId),
                color: colorRed,
                child: Scrollbar(
                  controller: scrollController,
                  child: ListView.builder(
                    controller: scrollController,
                    shrinkWrap: true,
                    itemCount: catNewsNotifier.length,
                    itemBuilder: (context, index) {
                      final newsItem = catNewsNotifier[index];
                      final dateTime = getDate(newsItem);

                      return buildExpansionWidget(
                        newsItem,
                        dateTime,
                        context,
                        newsNotifierController,
                        ref,
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// class CategoryScreen extends ConsumerStatefulWidget {
//   const CategoryScreen({super.key});
//
//   @override
//   ConsumerState createState() => _CategoryScreenState();
// }
//
// class _CategoryScreenState extends ConsumerState<CategoryScreen> {
//
//   @override
//   void initState() {
//     ref.read(categoryNotifierProvider.notifier).fetchCategoryData();
//     log('INIT');
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final categories = ref.watch(categoryNotifierProvider);
//
//     log('${categories.length}');
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Select Category'),
//       ),
//       body: ListView.builder(
//         itemCount: categories.length,
//         itemBuilder: (context, index) {
//           log('${categories.length}');
//           return ListTile(
//             title: Text('${categories[index].title}'),
//           );
//         },
//       ),
//     );
//   }
// }

/// Top Column
/*

Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        canGoToPreviousPage ? previous() : null;
                      },
                      child: Text(
                        'Previous',
                        style: TextStyle(
                          color:
                              canGoToPreviousPage ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        canGoToNextPage ? next() : null;
                      },
                      child: Text(
                        'Next',
                        style: TextStyle(
                          color: canGoToNextPage ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )

 */

/// Bottom Code

/*

return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 40),
                            child: Text(
                              dateTime,
                            ),
                          ),
                          ListTile(
                            minLeadingWidth: 40 - 10,
                            title: Text(
                              newsItem.titleText,
                              style: const TextStyle(fontSize: 17),
                            ),
                            leading: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    newsNotifierController.toggleFavStatus(
                                      newsItem.entryId,
                                      context,
                                    );

                                    // log(newsItem.id.toString());
                                  },
                                  child: Icon(
                                    catNewsNotifier[index].isFav
                                        ? Icons.bookmark_added
                                        : Icons.bookmark_add,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () {
                                    Status stat;

                                    if (newsItem.status == Status.read) {
                                      stat = Status.unread;
                                    } else {
                                      stat = Status.read;
                                    }

                                    newsNotifierController.toggleRead(
                                      newsItem.entryId,
                                      stat,
                                      context,
                                    );
                                  },
                                  child: Icon(
                                    size: 27,
                                    color: colorRed,
                                    newsItem.status == Status.unread
                                        ? Icons.circle
                                        : Icons.circle_outlined,
                                  ),
                                ),
                              ],
                            ),
                            // Bottom Section
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Image.network(
                                //   newsItem.imageUrl,
                                //   height: 90,
                                //   width: 130,
                                //   fit: BoxFit.cover,
                                // ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const SizedBox(height: 5),
                                    ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 190),
                                      child: Text(
                                        textAlign: TextAlign.end,
                                        '-- ${newsItem.author}',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                    Text('${newsItem.readTime} mins read'),
                                    GestureDetector(
                                      onTap: () async {
                                        Navigator.of(context).pushNamed(
                                          NewsDetailsScreen.routeNamed,
                                          arguments: {
                                            'id': newsItem.entryId,
                                            'image': newsItem.imageUrl,
                                            'content': newsItem.content,
                                            'selectedFeed': await ref
                                                .watch(homeFeedProvider.notifier)
                                                .viewEntryDetails(newsItem.feedId,
                                                    newsItem.entryId),
                                            'link': newsItem.link,
                                            'publishedAt': dateTime,
                                          },
                                        );
                                      },
                                      child: const Text('read more'),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          const Divider(thickness: 1),
                        ],
                      )

 */
