import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/common/common_widgets.dart';
import 'package:news_app/components/app_back_button.dart';
import 'package:news_app/features/subscription/screens/add_subscription_screen.dart';

import 'package:news_app/common/model_sheet.dart';
import '../../../common/constants.dart';
import '../repository/subscription_repository.dart';
import 'package:news_app/models/model.dart';
import '../widgets/clear_subscription_widget.dart';
import '../widgets/tile_build_methods.dart';
import '../widgets/subscription_tile.dart';

/// Providers
final isLoadingSubsProvider = StateProvider((ref) => false);

/// Widget
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
            .read(subscriptionNotifierProvider.notifier)
            .fetchCategories(context)
            .then(
              (_) => isLoadingSubsController.update((state) => false),
            );
        return null;
      },
      [],
    );

    final categoryListNotifier = ref.watch(subscriptionNotifierProvider);

    Future<void> refresh() async {
      isLoadingSubsController.update((state) => true);

      ref
          .read(subscriptionNotifierProvider.notifier)
          .fetchCategories(context)
          .then(
            (_) => isLoadingSubsController.update((state) => false),
          );
    }

    final scrollController = ScrollController();

    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    final isMacOs = defaultTargetPlatform == TargetPlatform.macOS;
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;

    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(
          controller: isDeletingCat,
        ),
        title: const Text('Select Subscription'),
        actions: [
          IconButton(
            onPressed: () => !isLoadingSubs
                ? context.pushNamed(AddSubscription.routeNamed)
                : null,
            icon: Icon(
              Icons.add,
              color: isLoadingSubs ? colorDisabled : colorRed,
            ),
          ),
        ],
      ),
      body: isLoadingSubs
          ? const LinearLoader()
          : categoryListNotifier.isEmpty
              ? const ClearSubscriptionWidget()
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
                        controller: scrollController,
                        child: Column(
                          children: [
                            const SizedBox(height: 5),
                            Expanded(
                              child: ListView.builder(
                                controller: scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
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
                                  } else if (isIos || isMacOs) {
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

