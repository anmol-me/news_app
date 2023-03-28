import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/common/common_widgets.dart';

import '../../../components/app_back_button.dart';
import '../../../models/model.dart';
import '../repository/manage_category_repository.dart';
import 'edit_feed_screen.dart';

/// Providers
final isManageLoadingProvider = StateProvider((ref) => false);

final isManageProcessingProvider = StateProvider((ref) => false);

/// Widgets
class ManageCategoryScreen extends HookConsumerWidget {
  static const routeNamed = '/manage-category-screen';

  final int catListItemId;
  final String catListItemTitle;

  const ManageCategoryScreen({
    super.key,
    required this.catListItemId,
    required this.catListItemTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isManageLoading = ref.watch(isManageLoadingProvider);
    final isManageLoadingController =
        ref.watch(isManageLoadingProvider.notifier);

    final isManageProcessing = ref.watch(isManageProcessingProvider);
    final isManageProcessingController =
        ref.watch(isManageProcessingProvider.notifier);

    useEffect(
      () {
        Future.delayed(Duration.zero)
            .then((_) => isManageLoadingController.update((state) => true));

        ref
            .read(manageCateNotifierProvider.notifier)
            .fetchCategoryFeeds(context, catListItemId)
            .then((_) => isManageLoadingController.update((state) => false));

        return null;
      },
      [],
    );

    final isManageNotifier = ref.watch(manageCateNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(catListItemTitle),
        leading: AppBackButton(
          controller: isManageProcessing,
        ),
      ),
      body: isManageLoading
          ? const LinearLoader()
          : Stack(
              children: [
                if (!isManageProcessing && isManageNotifier.isEmpty)
                  const Text('List is Empty')
                else if (isManageProcessing)
                  const LinearLoader()
                else
                  Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: isManageNotifier.length,
                          itemBuilder: (listContext, i) {
                            final item = isManageNotifier[i];

                            return ListTile(
                              leading: Text('${item.id}'),
                              title: Text(item.title),
                              trailing: Wrap(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      context.pushNamed(
                                        EditFeedScreen.routeNamed,
                                        queryParams: {
                                          'feedTitle': item.title,
                                          'feedId': item.id.toString(),
                                          'catId': catListItemId.toString(),
                                        },
                                        extra: {'listContext' : listContext},
                                      );

                                      /// Todo: Nav
                                      // Navigator.of(listContext).pushNamed(
                                      //   EditFeedScreen.routeNamed,
                                      //   arguments: {
                                      //     'feedTitle': item.title,
                                      //     'feedId': item.id,
                                      //     'catId': catListItemId,
                                      //     'listContext': listContext,
                                      //   },
                                      // );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Theme.of(listContext).colorScheme.error,
                                    ),
                                    onPressed: () {
                                      isManageProcessingController.update(
                                        (state) => true,
                                      );

                                      ref
                                          .read(manageCateNotifierProvider
                                              .notifier)
                                          .deleteCatFeed(
                                            context,
                                            item,
                                          )
                                          .then(
                                        (_) {
                                          return isManageProcessingController
                                              .update((state) => false);
                                        },
                                      );
                                    },
                                  ),
                                ],
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
