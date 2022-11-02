import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/features/subscription/screens/select_subscription_screen.dart';
import 'package:news_app/features/home/screens/home_feed_screen.dart';
import 'package:news_app/widgets/snack_bar.dart';

import '../common/common_widgets.dart';
import '../features/authentication/repository/auth_repo.dart';
import '../features/category/screens/manage_categories_screen.dart';
import '../features/home/providers/home_providers.dart';
import '../features/home/repository/home_feed_repo.dart';
import '../features/subscription/screens/category_screen.dart';
import '../models/user_providers.dart';

class AppDrawer extends HookConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // print('####### AppDrawer ########');

    final size = MediaQuery.of(context).size;
    // final userInfo = ref.watch(userNotifierProvider);

    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            buildHeader(context, size, ref),
            buildMenuItems(context, ref),
          ],
        ),
      ),
    );
  }
}

Widget buildHeader(
  BuildContext context,
  Size size,
  WidgetRef ref,
) =>
    Material(
      // color: Colors.grey[50],
      child: Container(
        height: size.height * 0.20,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Text(
                      'Feeds',
                      style: TextStyle(fontSize: 26),
                    ),
                    ref.watch(userNotifierFuture(context)).when(
                          data: (data) {
                            String username = '';
                            if (data != null) {
                              username =
                                  data[0].username.toString().capitalize();
                            }

                            return Text(
                              'Welcome $username',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            );
                          },
                          error: (e, s) {
                            log('$e');
                            showSnackBar(context: context, text: '$e');
                            return Container();
                          },
                          loading: () => const Center(
                            child: Text(
                              'Loading...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );

Widget buildMenuItems(BuildContext context, WidgetRef ref) {
  final isStarred = ref.watch(homeIsStarredProvider);
  final isStarredController = ref.read(homeIsStarredProvider.notifier);
  final isLoadingPageController = ref.read(homeIsLoadingPageProvider.state);

  final navigator = Navigator.of(context);

  return Wrap(
    runSpacing: 1,
    children: [
      ListTile(
        leading: const Icon(Icons.home_outlined),
        title: const Text('All Items'),
        onTap: () => refresh(
          navigator,
          ref,
          context,
          isLoadingPageController,
        ),
      ),
      ListTile(
        leading: Icon(isStarred ? Icons.star : Icons.star_border_outlined),
        title: const Text('Starred Items'),
        onTap: () {
          isLoadingPageController.update((state) => true);

          isStarredController.update((state) => !state);
          navigator.pop();

          navigator.pushNamed(HomeFeedScreen.routeNamed);

          // ref.refresh(homeFeedProvider.notifier).fetchEntries(context).then(
          //       (value) => isLoadingPageController.update((state) => false),
          //     );
          isLoadingPageController.update((state) => false);
        },
      ),
      ListTile(
        leading: const Icon(Icons.subscriptions_rounded),
        title: const Text('Subscription'),
        onTap: () {
          navigator.pop();
          ref.refresh(catSortProvider);
          navigator.pushNamed(SelectSubscriptionScreen.routeNamed);
        },
      ),
      const Divider(
        color: Colors.black54,
        thickness: 0.6,
      ),
      // ListTile(
      //   leading: const Icon(Icons.category_outlined),
      //   title: const Text('Show All Feeds'),
      //   onTap: () {
      //     Navigator.of(context).pop();
      //     Navigator.of(context).pushNamed(AllFeedsScreen.routeNamed);
      //   },
      // ),
      ListTile(
        leading: const Icon(Icons.settings),
        title: const Text('Settings'),
        onTap: () {
          // TODO: Settings
          navigator.pop();
        },
      ),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Logout'),
        onTap: () {
          navigator.pop();
          ref.read(authRepoProvider).logout(context);
        },
      ),
    ],
  );
}

/*
              Container(
                height: size.height * 0.30,
                color: Colors.grey,

                child: Text(
                  'Welcome ${userInfo[0].username.capitalize()}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
 */

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

Future<void> refresh(
  NavigatorState navigator,
  WidgetRef ref,
  BuildContext context,
  StateController<bool> isLoadingPageController,
) async {
  navigator.pop();
  isLoadingPageController.update((state) => true);

  ref.refresh(homeOffsetProvider);
  ref.refresh(homeSortDirectionProvider);
  ref.refresh(homeIsStarredProvider);
  ref.refresh(homeIsShowReadProvider);

  isLoadingPageController.update((state) => false);
  navigator.pushNamed('/');

  // bool isMainRouteSameAsCurrent = false;
  //
  // // navigator.popUntil((route) {
  // //   if (route.settings.name != '/') {
  // //     isMainRouteSameAsCurrent = false;
  // //   } else {
  // //     isMainRouteSameAsCurrent = true;
  // //   }
  // //   log('Check & set');
  // //   return true;
  // // });
  // //
  // // if (isMainRouteSameAsCurrent) {
  // //   log('On Root: Refresh!');
  // //   // ref.refresh(homeFeedProvider.notifier).fetchEntries(context).then(
  // //   //   (_) {
  // //   //     isLoadingPageController.update((state) => false);
  // //   //   },
  // //   // );
  // //
  // //   isLoadingPageController.update((state) => false);
  // //   navigator.pushNamed('/');
  // // } else {
  // //   log('Not on Root: Navigate to /');
  // //   isLoadingPageController.update((state) => false);
  // //   navigator.pushNamed('/');
  // // }
}
