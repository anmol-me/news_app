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
import '../../config/themes.dart';
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
    final currentWidth = MediaQuery.of(context).size.width;

    // Using useEffect in place of init()
    // Fetches User data only once
    useEffect(
      () {
        final isDemoPref = ref.read(userPrefsProvider).getIsDemo() ?? false;
        final isUserEmpty =
            ref.read(userNotifierProvider)?.username.isEmpty ?? false;

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

    final themeMode = ref.watch(themeModeProvider);
    final isLight = themeMode == ThemeMode.light;

    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const BuildDrawerHeader(),
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
                        onTap: () {
                          if (currentWidth <= 650) {
                            Navigator.of(context).pop();
                          }

                          ref
                            .read(refreshProvider)
                            .refreshAllMain(context);
                        },
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
                        onTap: () {
                          if (currentWidth <= 650) {
                            Navigator.of(context).pop();
                          }

                          final isDemoPref =
                              ref.read(userPrefsProvider).getIsDemo() ?? false;
                          if (isDemoPref) {
                            appBarRepo.starredDemoFunction(context);
                            return;
                          }

                          appBarRepo.starredFunction(context);
                        },
                      ),
                ListTile(
                  leading: const Icon(Icons.subscriptions_rounded),
                  title: const Text('Subscription'),
                  onTap: () {
                    if (currentWidth <= 650) {
                      Navigator.of(context).pop();
                    }

                    ref.refresh(catSortProvider).value;
                    context.pushNamed(SelectSubscriptionScreen.routeNamed);
                  },
                ),
                Divider(
                  color: isLight ? Colors.black87 : Colors.white,
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
                  onTap: () {
                    Navigator.of(context).pop();
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

class BuildDrawerHeader extends HookConsumerWidget {
  const BuildDrawerHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoadingName = ref.watch(isLoadingNameProvider);

    final userNameLoaded =
        ref.watch(userNotifierProvider)?.username.capitalize() ?? ' Loading...';

    return DrawerHeader(
      decoration: BoxDecoration(
        border: Border(
          bottom: Divider.createBorderSide(
            context,
            color: colorRed,
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
