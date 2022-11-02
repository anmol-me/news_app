import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/common/common_widgets.dart';
import 'package:news_app/features/authentication/repository/auth_repo.dart';
import 'package:news_app/features/subscription/screens/add_subscription_screen.dart';
import 'package:news_app/features/subscription/screens/category_screen.dart';
import 'package:news_app/features/subscription/screens/edit_subscription_screen.dart';
import 'package:news_app/features/home/widgets/model_sheet.dart';

import '../../../common/constants.dart';
import '../repository/add_new_subscription_repo.dart';
import '../repository/category_list_repo.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

final isLoadingSubsProvider = StateProvider((ref) => false);

/// -

class SelectSubscriptionScreen extends HookConsumerWidget {
  static const routeNamed = '/select-subs';

  const SelectSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoadingSubs = ref.watch(isLoadingSubsProvider);
    final isLoadingSubsController = ref.watch(isLoadingSubsProvider.notifier);

    useEffect(
      () {
        Future.delayed(Duration.zero).then(
          (value) => isLoadingSubsController.update((state) => true),
        );

        ref
            .read(categoryListNotifierProvider.notifier)
            .fetchCategories(context)
            .then(
              (_) => isLoadingSubsController.update((state) => false),
            );
        return null;
      },
      [],
    );

    final categoryListNotifier = ref.watch(categoryListNotifierProvider);

    Future<void> refresh() async {
      isLoadingSubsController.update((state) => true);

      ref
          .read(categoryListNotifierProvider.notifier)
          .fetchCategories(context)
          .then(
            (_) => isLoadingSubsController.update((state) => false),
          );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Subscription'),
        actions: [
          IconButton(
            onPressed: () => !isLoadingSubs
                ? Navigator.of(context).pushNamed(AddSubscription.routeNamed)
                : null,
            icon: Icon(
              Icons.add,
              color: isLoadingSubs ? colorAppbarForeground : colorRed,
            ),
          ),
        ],
      ),
      body: isLoadingSubs
          ? const LinearLoader()
          : RefreshIndicator(
              onRefresh: refresh,
              color: colorRed,
              child: Scrollbar(
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    Expanded(
                      child: ListView.builder(
                        itemCount: categoryListNotifier.length,
                        itemBuilder: (context, index) {
                          final subscriptionItem = categoryListNotifier[index];

                          return Slidable(
                            direction: Axis.horizontal,
                            endActionPane: ActionPane(
                              extentRatio: 0.6,
                              motion: const StretchMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    showCupertinoSheet(
                                        context, subscriptionItem);
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
                                        .read(
                                            addNewSubscriptionProvider.notifier)
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
                                  onPressed: (context) {
                                    /// Todo:
                                  },
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  icon: Icons.archive,
                                  label: 'Archive',
                                ),
                              ],
                            ),
                            child: SubscriptionButton(
                              id: subscriptionItem.id,
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
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class SubscriptionButton extends ConsumerWidget {
  final int id;
  final List<Widget> children;

  const SubscriptionButton(
      {super.key, required this.id, required this.children});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryListNotifier = ref.watch(categoryListNotifierProvider);
    final subscriptionItem = categoryListNotifier.firstWhere((e) => e.id == id);

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          CategoryScreen.routeNamed,
          arguments: {
            'id': subscriptionItem.id,
            'catTitle': subscriptionItem.title
          },
        );

        /// Todo: Check
        // ref.read(categoryListNotifierProvider).clear();
      },
      child: ListTile(
        // leading: Text('${subscriptionItem.id}'),
        title: Text(subscriptionItem.title),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: children,
          ),
        ),
      ),
    );
  }
}
