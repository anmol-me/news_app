import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:news_app/features/category/screens/show_category_feeds_screen.dart';
import 'package:news_app/widgets/app_drawer.dart';

import '../../home/widgets/model_sheet.dart';
import '../../subscription/repository/add_new_subscription_repo.dart';
import '../../subscription/repository/category_list_repo.dart';
import '../../subscription/screens/edit_subscription_screen.dart';

final categoryIdProvider = StateProvider<int>((ref) => 0);

class AllFeedsScreen extends ConsumerWidget {
  static const routeNamed = '/manage-categories-screen';

  // final String oldTitle;
  // final int listItemId;

  const AllFeedsScreen({
    super.key,
    // required this.oldTitle,
    // required this.listItemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryIdController = ref.read(categoryIdProvider.notifier);

    // final categoryListFetcher = ref.read(categoryListNotifierProvider.notifier).fetchTry(context);

    // final categoryListFetcher = ref.read(categoryListNotifierProvider.notifier);
    final categoryListFetcher = ref.watch(categoryListNotifierProvider);

    // final categoryListFuture = ref.watch(categoryListNotifierFuture(context));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Cate'),
        // actions: [],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: categoryListFetcher.length,
              itemBuilder: (context, index) {
                final subscriptionItem = categoryListFetcher[index];

                return Slidable(
                  direction: Axis.horizontal,
                  endActionPane: ActionPane(
                    extentRatio: 0.6,
                    motion: const StretchMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          showCupertinoSheet(context, subscriptionItem);
                        },
                        backgroundColor: Colors.deepOrangeAccent,
                        foregroundColor: Colors.white,
                        icon: Icons.more_horiz,
                        label: 'More',
                      ),
                      SlidableAction(
                        spacing: 6,
                        onPressed: (context) {
                          ref
                              .read(addNewSubscriptionProvider.notifier)
                              .deleteFeed(
                                context,
                                subscriptionItem.id,
                                subscriptionItem.title,
                              );
                          // Will pop after.
                        },
                        backgroundColor: const Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: CupertinoIcons.delete,
                        label: 'Delete',
                      ),
                      SlidableAction(
                        spacing: 6,
                        onPressed: (context) {
                          Navigator.of(context).pushNamed(
                            EditSubscription.routeNamed,
                            arguments: {
                              'oldTitle': subscriptionItem.title,
                              'listItemId': subscriptionItem.id,
                            },
                          );
                        },
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                    ],
                  ),
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {},
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        icon: Icons.archive,
                        label: 'Archive',
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      categoryIdController
                          .update((state) => subscriptionItem.id);

                      Navigator.of(context).pushNamed(
                        ShowCategoryFeedsScreen.routeNamed,
                        arguments: {
                          'title': subscriptionItem.title,
                          // 'catTitle': subscriptionItem.title
                        },
                      );
                    },
                    child: ListTile(
                      leading: Text('${subscriptionItem.id}'),
                      title: Text(subscriptionItem.title),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // IconButton(
                            //   onPressed: () {
                            //     Navigator.of(context).pushNamed(
                            //       EditSubscription.routeNamed,
                            //       arguments: {
                            //         'oldTitle': subscriptionItem.title,
                            //         'listItemId': subscriptionItem.id,
                            //       },
                            //     );
                            //   },
                            //   icon: const Icon(
                            //     Icons.edit,
                            //     color: Colors.blue,
                            //   ),
                            // ),
                            IconButton(
                              onPressed: () {
                                showModelSheet(
                                  context: context,
                                  listItem: subscriptionItem,
                                  ref: ref,
                                );
                              },
                              icon: const Icon(
                                Icons.more_vert,
                                // color: Theme.of(context).errorColor,
                              ),
                            ),
                            // IconButton(
                            //   onPressed: () {},
                            //   icon: Icon(
                            //     Icons.delete,
                            //     color: Theme.of(context).errorColor,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // categoryListFuture.when(
            //   data: (data) {
            //     return ;
            //   },
            //   error: (e, s) {
            //     return Container(
            //         decoration:
            //         BoxDecoration(color: Colors.deepOrangeAccent[100]),
            //         child: Center(child: Text('Error... $e')));
            //   },
            //   loading: () {
            //     return const Center(child: Text('Loading...'));
            //   },
            // ),
          ),
        ],
      ),
    );
  }
}
