import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/common/common_methods.dart';
import 'package:news_app/features/app_bar/app_bar_repo.dart';
import 'package:news_app/features/app_bar/user_repository.dart';
import 'package:news_app/features/subscription/screens/select_subscription_screen.dart';

import '../../common/common_providers.dart';
import '../../common/constants.dart';
import '../authentication/repository/auth_repo.dart';
import '../authentication/repository/user_preferences.dart';
import '../home/providers/home_providers.dart';
import '../settings/screens/settings_screen.dart';
import '../category/screens/category_screen.dart';

/// Provider
final isLoadingNameProvider = StateProvider((ref) => false);

final isInitProvider = StateProvider((ref) {
  final isStateEmpty =
      ref.watch(userNotifierProvider)?.username.isEmpty ?? false;
  return isStateEmpty;
});

/// Widgets
class AppDrawer extends HookConsumerWidget {
  static const routeNamed = '/app-drawer';

  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Using useEffect in place of init()
    // Fetches User data only once
    useEffect(
      () {
        final isDemoPref = ref.read(userPrefsProvider).getIsDemo() ?? false;
        final isUserEmpty = ref.read(userNotifierProvider)?.username.isEmpty ?? false;

        if (isDemoPref && isUserEmpty) {
          ref.read(userNotifierProvider.notifier).fetchDemoUserData(context);
          return;
        }

        final isInit = ref.read(isInitProvider);

        if (isInit) {
          final isLoadingNameController =
              ref.read(isLoadingNameProvider.notifier);

          Future.delayed(Duration.zero)
              .then((_) => isLoadingNameController.update((state) => true));

          Future.delayed(Duration.zero).then(
            (_) => ref
                .read(userNotifierProvider.notifier)
                .fetchUserData(context)
                .then(
                  (_) => isLoadingNameController.update((state) => false),
                ),
          );

          Future.delayed(Duration.zero).then(
            (_) => ref.read(isInitProvider.notifier).update((state) => false),
          );
        }
        return null;
      },
      [],
    );

    final appBarRepo = ref.read(appBarRepoProvider);
    final isStarred = ref.watch(isStarredProvider);
    final emptyStateDisable = ref.watch(emptyStateDisableProvider);

    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const BuildHeader(),
            Divider(
              color: colorRed,
              thickness: 1.5,
              indent: 60,
              endIndent: 60,
            ),
            Wrap(
              runSpacing: 1,
              children: [
                emptyStateDisable
                    ? ListTile(
                        leading: Icon(
                          Icons.home_outlined,
                          color: colorDisabled,
                        ),
                        title: Text(
                          'All Items',
                          style: TextStyle(
                            color: colorDisabled,
                          ),
                        ),
                        onTap: null,
                      )
                    : ListTile(
                        leading: const Icon(Icons.home_outlined),
                        title: const Text('All Items'),
                        onTap: () =>
                            ref.read(refreshProvider).refreshAllMain(context),
                      ),
                emptyStateDisable
                    ? ListTile(
                        leading: Icon(
                          Icons.star_border_outlined,
                          color: colorDisabled,
                        ),
                        title: Text(
                          'Starred Items',
                          style: TextStyle(
                            color: colorDisabled,
                          ),
                        ),
                        onTap: null,
                      )
                    : ListTile(
                        leading: Icon(
                          isStarred ? Icons.star : Icons.star_border_outlined,
                        ),
                        title: const Text('Starred Items'),
                        onTap: () => appBarRepo.starredFunction(context),
                      ),
                ListTile(
                  leading: const Icon(Icons.subscriptions_rounded),
                  title: const Text('Subscription'),
                  onTap: () {
                    if (ref.read(isHomeDrawerOpened)) {
                      Navigator.of(context).pop();
                    }
                    ref.refresh(catSortProvider).value;
                    context.pushNamed(SelectSubscriptionScreen.routeNamed);
                  },
                ),
                const Divider(
                  color: Colors.black54,
                  thickness: 0.6,
                  indent: 60,
                  endIndent: 60,
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () => context.pushNamed(SettingsScreen.routeNamed),
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () => ref.read(authRepoProvider).logout(context),
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
        ref.watch(userNotifierProvider)?.username.capitalize() ?? ' Loading...';

    return Material(
      child: Container(
        height: size.height * 0.17,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40),
        child: Row(
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
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
