import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../subscription/repository/add_new_subscription_repo.dart';
import '../repository/manage_categories_repository.dart';

class ShowCategoryFeedsScreen extends ConsumerWidget {
  static const routeNamed = '/show-category-feeds-screen';

  final String categoryTitle;

  const ShowCategoryFeedsScreen({
    super.key,
    required this.categoryTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final showCategoryFeed = ref
    //     .read(manageCategoriesRepoProvider.notifier)
    //     .fetchCategoryFeeds(context, feedId);

    final manageCategoriesRepoFetcher =
        ref.watch(manageCategoriesRepoFuture(context));

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: manageCategoriesRepoFetcher.when(
              data: (data) {
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    return ListTile(
                      title: Text(data[i].title),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // ref
                          //     .read(addNewSubscriptionProvider.notifier)
                          //     .deleteFeed(
                          //       context,
                          //       data[i].id,
                          //       data[i].title,
                          //     );
                          // // Will pop after.
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
          Expanded(
            child: Text(''),
          ),
        ],
      ),
    );
  }
}
