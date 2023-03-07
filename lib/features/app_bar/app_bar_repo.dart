import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/features/home/screens/home_feed_screen.dart';

import '../../common/enums.dart';
import '../home/providers/home_providers.dart';
import '../home/repository/home_feed_repo.dart';

final appBarRepoProvider = Provider(
  (ref) {
    final isLoadingPageController = ref.watch(homePageLoadingProvider.notifier);

    return AppBarRepository(ref, isLoadingPageController);
  },
);

class AppBarRepository {
  final ProviderRef ref;
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

    log('PATH: ${GoRouterState.of(context).location}');

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

    /// Nav-> TODO:
    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeFeedScreen()));
  }

  Future<void> refreshAllDrawer(
    BuildContext context,
  ) async {
    // log("---> ${ModalRoute.of(context)!.settings.name}");
    log("Refresh Drawer---> ${GoRouterState.of(context).path}");

    Navigator.of(context).pop();
    isLoadingPageController.update((state) => true);

    refreshProviders(ref);

    // if (ModalRoute.of(context)!.settings.name == 'homeScreen') {
    //   ref.refresh(homeFeedProvider.notifier).fetchEntries(context).then(
    //         (_) => isLoadingPageController.update((state) => false),
    //       );
    // } else {
    //   isLoadingPageController.update((state) => false);
    //   context.pushNamed(HomeFeedScreen.routeNamed);
    //
    //   /// Todo: Nav
    //   // navigator.pushNamed('/');
    // }

    if (GoRouterState.of(context).location == '/home') {
      ref.refresh(homeFeedProvider.notifier).fetchEntries(context).then(
            (_) => isLoadingPageController.update((state) => false),
          );
    } else {
      context.goNamed(HomeFeedScreen.routeNamed);
      ref.refresh(homeFeedProvider.notifier).fetchEntries(context).then(
            (_) => isLoadingPageController.update((state) => false),
          );
    }
  }
}
