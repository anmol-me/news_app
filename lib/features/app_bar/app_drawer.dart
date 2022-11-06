import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/features/app_bar/user.dart';
import 'package:news_app/features/subscription/screens/select_subscription_screen.dart';
import 'package:news_app/features/home/screens/home_feed_screen.dart';

import '../../common/common_widgets.dart';
import '../authentication/repository/auth_repo.dart';
import '../home/providers/home_providers.dart';
import '../home/repository/home_feed_repo.dart';
import '../starred/starred_screen.dart';
import '../subscription/screens/category_screen.dart';
import 'user_providers.dart';

/// Provider
final isLoadingNameProvider = StateProvider((ref) => false);

final isInitProvider = StateProvider((ref) => true);

class AppDrawer extends HookConsumerWidget {
  static const routeNamed = '/app-drawer';

  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(
      () {
        final isInit = ref.read(isInitProvider);

        if (isInit) {
          final isLoadingNameController =
              ref.read(isLoadingNameProvider.notifier);

          Future.delayed(Duration.zero)
              .then((value) => isLoadingNameController.update((state) => true));

          Future.delayed(Duration.zero).then(
            (value) => ref
                .read(userNotifierProvider.notifier)
                .fetchUserData(context)
                .then(
                  (_) => isLoadingNameController.update((state) => false),
                ),
          );
        }

        Future.delayed(Duration.zero).then(
          (_) => ref.read(isInitProvider.notifier).update((state) => false),
        );
        return null;
      },
      [],
    );

    void starredFunction(
      StateController<bool> isLoadingPageController,
      StateController<bool> isStarredController,
      NavigatorState navigator,
    ) {
      isLoadingPageController.update((state) => true);

      isStarredController.update((state) => !state);
      navigator.pop();

      if (ModalRoute.of(context)!.settings.name == '/') {
        ref.refresh(homeFeedProvider.notifier).fetchEntries(context).then(
              (_) => isLoadingPageController.update((state) => false),
            );
      } else {
        isLoadingPageController.update((state) => false);
        navigator.pushNamed(HomeFeedScreen.routeNamed);
      }
    }

    final isStarred = ref.watch(isStarredProvider);
    final isStarredController = ref.watch(isStarredProvider.notifier);

    final isLoadingStarred = ref.watch(isLoadingStarredProvider);
    final isLoadingStarredController =
        ref.watch(isLoadingStarredProvider.notifier);

    final isLoadingPageController =
        ref.watch(homeIsLoadingPageProvider.notifier);

    final navigator = Navigator.of(context);

    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const BuildHeader(),
            Wrap(
              runSpacing: 1,
              children: [
                ListTile(
                  leading: const Icon(Icons.home_outlined),
                  title: const Text('All Items'),
                  onTap: () => refreshAll(
                    navigator,
                    ref,
                    context,
                    isLoadingPageController,
                  ),
                ),
                ListTile(
                  leading: Icon(
                    isStarred ? Icons.star : Icons.star_border_outlined,
                  ),
                  title: const Text('Starred Items'),
                  onTap: () {
                    isStarredController.update((state) => true);

                    navigator.pushNamed(StarredScreen.routeNamed);
                    //   starredFunction(
                    //   isLoadingPageController,
                    //   isStarredController,
                    //   navigator,
                    // );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.subscriptions_rounded),
                  title: const Text('Subscription'),
                  onTap: () {
                    navigator.pop();
                    ref.refresh(catSortProvider).value;
                    refreshProviders(ref);
                    navigator.pushNamed(SelectSubscriptionScreen.routeNamed);
                  },
                ),
                const Divider(
                  color: Colors.black54,
                  thickness: 0.6,
                ),
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
            ),
          ],
        ),
      ),
    );
  }
}

class BuildHeader extends HookConsumerWidget {
  const BuildHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoadingName = ref.watch(isLoadingNameProvider);

    final size = MediaQuery.of(context).size;

    final userNameLoaded =
        ref.read(userNotifierProvider)?.username.capitalize() ?? ' to App';

    return Material(
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
                    Text(
                      isLoadingName ? 'Loading...' : 'Welcome $userNameLoaded',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
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
  }
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

Future<void> refreshAll(
  NavigatorState navigator,
  WidgetRef ref,
  BuildContext context,
  StateController<bool> isLoadingPageController,
) async {
  navigator.pop();
  log(ModalRoute.of(context)!.settings.name.toString());

  refreshProviders(ref);

  if (ModalRoute.of(context)!.settings.name == '/') {
    isLoadingPageController.update((state) => true);
    ref.refresh(homeFeedProvider.notifier).fetchEntries(context).then(
          (_) => isLoadingPageController.update((state) => false),
        );
  } else {
    navigator.pushNamed('/');
  }
}

/*
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
                          loading: () => Center(
                            child: Text(
                              nameLoading,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
 */
