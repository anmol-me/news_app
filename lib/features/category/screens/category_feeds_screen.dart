import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/common/common_widgets.dart';

import '../../../models/model.dart';
import '../../subscription/repository/add_new_subscription_repo.dart';
import '../../subscription/repository/category_list_repo.dart';
import '../repository/category_feed_repository.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

// final catDetailsProvider =
//     StateProvider<CategoryList>((ref) => CategoryList(id: 0, title: ''));
//
// final catDetailsContextProvider = StateProvider<BuildContext?>((ref) => null);

// final disableCatCheckProvider = StateProvider((ref) => false);

final isCatFeedLoadingProvider = StateProvider((ref) => false);

final isCatFeedDeletingProvider = StateProvider((ref) => false);

class CategoryFeedsScreen extends HookConsumerWidget {
  static const routeNamed = '/show-category-feeds-screen';

  final CategoryList listItem;

  const CategoryFeedsScreen({
    super.key,
    required this.listItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final showCategoryFeed = ref
    //     .read(manageCategoriesRepoProvider.notifier)
    //     .fetchCategoryFeeds(context, feedId);

    // final catFeedsRepoFetcher = ref.watch(catFeedRepoFuture(context));

    // final deleteCatFeed = ref.watch(deleteCatFeedFuture(context));

    final isCatFeedLoading = ref.watch(isCatFeedLoadingProvider);
    final isCatFeedLoadingController =
        ref.watch(isCatFeedLoadingProvider.notifier);

    final isCatFeedDeleting = ref.watch(isCatFeedDeletingProvider);
    final isCatFeedDeletingController =
        ref.watch(isCatFeedDeletingProvider.notifier);

    useEffect(
      () {
        Future.delayed(Duration.zero)
            .then((_) => isCatFeedLoadingController.update((state) => true));

        ref
            .read(catFeedRepoProvider.notifier)
            .fetchCategoryFeeds(context, listItem.id)
            .then((_) => isCatFeedLoadingController.update((state) => false));

        return null;
      },
      [],
    );

    final catFeedRepo = ref.watch(catFeedRepoProvider);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(listItem.title),
      ),
      body: isCatFeedLoading
          ? const LinearLoader()
          : Stack(
              children: [
                if (isCatFeedDeleting && catFeedRepo.isEmpty)
                  const LinearLoader()
                else if (!isCatFeedDeleting && catFeedRepo.isEmpty)
                  const Text('List is Empty')
                else if (isCatFeedDeleting)
                  const LinearLoader()
                else
                  Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: catFeedRepo.length,
                          itemBuilder: (context, i) {
                            final item = catFeedRepo[i];

                            return ListTile(
                              leading: Text('${item.id}'),
                              title: Text(item.title),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  isCatFeedDeletingController.update(
                                    (state) => true,
                                  );

                                  ref
                                      .read(catFeedRepoProvider.notifier)
                                      .deleteCatFeed(
                                        _scaffoldKey.currentContext!,
                                        item,
                                      )
                                      .then(
                                    (_) {
                                      return isCatFeedDeletingController
                                          .update((state) => false);
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      // Expanded(
                      //   child: Text(''),
                      // ),
                    ],
                  ),
              ],
            ),
    );
  }
}

/*
          Expanded(
            child: catFeedsRepoFetcher.when(
              data: (data) {
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    return ListTile(
                      leading: Text('${data[i].id}'),
                      title: Text(data[i].title),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // ref
                          //     .read(catDetailsContextProvider.notifier)
                          //     .update((state) => context);
                          //
                          // ref.read(catDetailsProvider.notifier).update(
                          //       (state) => data[i],
                          //     );

                          ref.read(catFeedRepoProvider.notifier).deleteFeed(context, data[i]);
                        },
                      ),
                    );
                  },
                );
              },
              error: (e, s) {
                return Container(
                    decoration:
                        BoxDecoration(color: Colors.deepOrangeAccent[100]),
                    child: Center(child: Text('Error... $e')));
              },
              loading: () {
                return const Center(child: Text('Loading...'));
              },
            ),
          ),
 */
