import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/features/home/screens/home_feed_screen.dart';

import '../../common/enums.dart';
import '../home/providers/home_providers.dart';

/// Provider
final appBarRepoProvider = Provider(
  (ref) {
    final isLoadingPageController = ref.watch(homePageLoadingProvider.notifier);

    return AppBarRepository(ref, isLoadingPageController);
  },
);

/// Class
class AppBarRepository {
  final Ref ref;
  final StateController<bool> isLoadingPageController;

  AppBarRepository(this.ref, this.isLoadingPageController);

  void starredFunction(
    BuildContext context,
  ) {
    final isStarredController = ref.read(isStarredProvider.notifier);

    isLoadingPageController.update((state) => true);
    Navigator.of(context).pop();

    isStarredController.update((state) => !state);

    ref.refresh(homeOffsetProvider.notifier).update((state) => 0);

    ref
        .refresh(homeOrderProvider.notifier)
        .update((state) => OrderBy.publishedAt);

    ref
        .refresh(homeSortDirectionProvider.notifier)
        .update((state) => Sort.descending);

    ref.refresh(homeIsShowReadProvider.notifier).update((state) => false);

    if (GoRouterState.of(context).location == '/home') {
      ref.read(homeFeedProvider.notifier).fetchEntries(context).then(
            (_) => isLoadingPageController.update((state) => false),
          );
    } else {
      context.goNamed(HomeFeedScreen.routeNamed);
      ref.read(homeFeedProvider.notifier).fetchEntries(context).then(
            (_) => isLoadingPageController.update((state) => false),
          );
    }
  }

  void starredDemoFunction(
    BuildContext context,
  ) {
    Navigator.of(context).pop();

    ref.read(isStarredProvider.notifier).update((state) => !state);
    final isStarred = ref.read(isStarredProvider);

    if (GoRouterState.of(context).location != '/home') {
      context.goNamed(HomeFeedScreen.routeNamed);
    }
    if (isStarred) {
      ref.read(homeFeedProvider.notifier).starredDemoEntries();
    } else {
      ref.refresh(homeFeedProvider.notifier).fetchDemoEntries(context);
    }
  }
}
