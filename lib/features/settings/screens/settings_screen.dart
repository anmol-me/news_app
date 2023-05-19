import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/common/constants.dart';
import 'package:news_app/common/file_repository.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../../common/enums.dart';
import '../../../common_widgets/common_widgets.dart';
import '../../../components/app_back_button.dart';
import '../../authentication/repository/user_preferences.dart';
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

    final isDemoPref = ref.watch(userPrefsProvider).getIsDemo() ?? false;

    final isWeb = UniversalPlatform.isWeb;
    final color = isWeb ? colorDisabled : Colors.black;

    final clearCacheTile = ListTile(
      title: Text(
        'Clear demo category cache',
        style: TextStyle(
          color: color,
        ),
      ),
      subtitle: Text(
        '(Web not supported)',
        style: TextStyle(
          color: colorSubtitle,
        ),
      ),
      trailing: isWeb
          ? Icon(Icons.clear_all, color: colorDisabled)
          : IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                ref.read(fileRepositoryProvider).deleteFile(
                      assetName: AssetFileName.categories.value,
                      context: context,
                    );
              },
            ),
    );

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
                if (isDemoPref) {
                  showErrorSnackBar(
                      context: context,
                      text: ErrorString.demoRefreshSettings.value);
                  return;
                }

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
          isDemoPref ? clearCacheTile : const SizedBox.shrink(),
          SwitchListTile(
            title: const Text('Enable Dark Mode'),
            activeColor: Colors.red.shade500,
            inactiveThumbColor: Colors.black,
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
