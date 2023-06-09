import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/components/clear_button.dart';
import 'package:news_app/features/subscription/widgets/subscription_refresh_button.dart';
import 'package:universal_platform/universal_platform.dart';

import 'package:news_app/common_widgets/common_widgets.dart';
import 'package:news_app/components/app_back_button.dart';
import 'package:news_app/features/subscription/screens/add_subscription_screen.dart';
import '../../../common/constants.dart';
import '../../authentication/repository/user_preferences.dart';
import '../repository/subscription_repository.dart';
import '../widgets/clear_subscription_widget.dart';
import '../widgets/tile_build_methods.dart';

/// Providers
final isLoadingSubsProvider = StateProvider((ref) => false);

/// Widget
class SelectSubscriptionScreen extends HookConsumerWidget {
  static const routeNamed = '/select-subs';

  const SelectSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();

    final isLoadingSubs = ref.watch(isLoadingSubsProvider);
    final isLoadingSubsController = ref.watch(isLoadingSubsProvider.notifier);

    final isDeletingCat = ref.watch(isDeletingCatProvider);

    // Using useEffect() instead of initState()
    useEffect(
      () {
        final isDemoPref = ref.read(userPrefsProvider).getIsDemo() ?? false;
        if (isDemoPref) {
          ref
              .read(subscriptionNotifierProvider.notifier)
              .fetchDemoCategories(context);
          return;
        }

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

    final isDemoPref = ref.watch(userPrefsProvider).getIsDemo() ?? false;

    final isIos = UniversalPlatform.isIOS;
    final isMacOs = UniversalPlatform.isMacOS;
    final isAndroid = UniversalPlatform.isAndroid;

    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(
          controller: isDeletingCat,
        ),
        title: const Text('Select Subscription'),
        actions: [
          isDemoPref
              ? categoryListNotifier.isNotEmpty
                  ? const SubscriptionClearButton()
                  : const SubscriptionRefreshButton()
              : const SizedBox.shrink(),
          !isLoadingSubs
              ? IconButton(
                  onPressed: () =>
                      context.pushNamed(AddSubscription.routeNamed),
                  icon: Icon(
                    Icons.add,
                    color: colorRed,
                  ),
                )
              : Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                    Icons.add,
                    color: colorDisabled,
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
