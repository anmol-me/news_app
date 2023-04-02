import 'dart:developer';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/common/common_widgets.dart';
import 'package:news_app/components/app_back_button.dart';
import 'package:news_app/features/subscription/screens/add_subscription_screen.dart';

import 'package:news_app/common/model_sheet.dart';
import '../../../../common/constants.dart';
import '../../../../main.dart';
import '../../repository/category_list_repo.dart';
import 'package:news_app/models/model.dart';
import 'build_methods.dart';
import 'subscription_tile.dart';

final isLoadingSubsProvider = StateProvider((ref) => false);

///
class SelectSubscriptionScreen extends HookConsumerWidget {
  static const routeNamed = '/select-subs';

  const SelectSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoadingSubs = ref.watch(isLoadingSubsProvider);
    final isLoadingSubsController = ref.watch(isLoadingSubsProvider.notifier);

    final isDeletingCat = ref.watch(isDeletingCatProvider);

    // Using useEffect() instead of initState()
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

    final isIos = defaultTargetPlatform == TargetPlatform.android;
    final isAndroid = defaultTargetPlatform == TargetPlatform.iOS;

    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(
          controller: isDeletingCat,
        ),
        title: const Text('Select Subscription'),
        actions: [
          IconButton(
            // onPressed: () => !isLoadingSubs
            //     ? Navigator.of(context).pushNamed(AddSubscription.routeNamed)
            //     : null,
            onPressed: () => !isLoadingSubs
                ? context.pushNamed(AddSubscription.routeNamed)
                : null,
            icon: Icon(
              Icons.add,
              color: isLoadingSubs ? colorAppbarForeground : colorRed,
            ),
          ),

          /// Clear
          IconButton(
            onPressed: () => ref.refresh(categoryListNotifierProvider).clear(),
            icon: Icon(
              Icons.clear,
              color: colorRed,
            ),
          ),
        ],
      ),
      body: isLoadingSubs
          ? const LinearLoader()
          : categoryListNotifier.isEmpty
              ? const ClearSubscriptionView()
              : RefreshIndicator(
                  onRefresh: refresh,
                  color: colorRed,
                  child: Stack(
                    children: [
                      if (isDeletingCat)
                        const Positioned(
                          child: LinearLoader(),
                        ),
                      Scrollbar(
                        child: Column(
                          children: [
                            const SizedBox(height: 5),
                            Expanded(
                              child: ListView.builder(
                                itemCount: categoryListNotifier.length,
                                itemBuilder: (listContext, index) {
                                  final subscriptionItem =
                                      categoryListNotifier[index];

                                  if (isAndroid) {
                                    return buildSubscriptionTile(
                                      subscriptionItem,
                                      ref,
                                      listContext,
                                    );
                                  } else if (isIos) {
                                    return buildSlidable(
                                      subscriptionItem,
                                      ref,
                                      listContext,
                                    );
                                  } else {
                                    return buildSubscriptionTile(
                                      subscriptionItem,
                                      ref,
                                      listContext,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

SubscriptionTile buildSubscriptionTile(
  CategoryList subscriptionItem,
  WidgetRef ref,
  BuildContext listContext,
) =>
    SubscriptionTile(
      id: subscriptionItem.id,
      children: [
        if (defaultTargetPlatform != TargetPlatform.iOS)
          IconButton(
            onPressed: () => showModelSheet(
              listContext: listContext,
              listItem: subscriptionItem,
              ref: ref,
            ),
            icon: const Icon(
              Icons.more_vert,
            ),
          ),
      ],
    );

class ClearSubscriptionView extends StatelessWidget {
  const ClearSubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Add subscription to get started',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

/*
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.delete,
                                        color: Theme.of(context).errorColor,
                                      ),
                                    ),




                                                                        IconButton(
                                      onPressed: () {
                                        Navigator.of(context).pushNamed(
                                          EditSubscription.routeNamed,
                                          arguments: {
                                            'oldTitle': subscriptionItem.title,
                                            'listItemId': subscriptionItem.id,
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                    ),
 */
