import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../components/app_back_button.dart';
import '../../home/providers/home_providers.dart';
import '../repository/settings_repository.dart';

/// Providers
final isRefreshAllLoadingProvider = StateProvider((ref) => false);

/// Widgets
class SettingsScreen extends HookConsumerWidget {
  static const routeNamed = '/settings-screen';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(userSettingsProvider);
    final themeStateController = ref.watch(userSettingsProvider.notifier);

    final isRefreshAllLoading = ref.watch(isRefreshAllLoadingProvider);
    final isRefreshAllLoadingController =
        ref.watch(isRefreshAllLoadingProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: const AppBackButton(
          controller: false,
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Refresh all feeds\n(in the background)'),
            trailing: IconButton(
              onPressed: () {
                isRefreshAllLoadingController.update((state) => true);
                ref.read(homeFeedProvider.notifier).refreshAll(context).then(
                    (_) =>
                        isRefreshAllLoadingController.update((state) => false));
              },
              icon: Icon(
                isRefreshAllLoading ? Icons.cached_rounded : Icons.refresh,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Enable Dark Mode'),
            value: themeState ?? false,
            onChanged: (val) {
              themeStateController.setThemeMode(val);
            },
          ),
        ],
      ),
    );
  }
}