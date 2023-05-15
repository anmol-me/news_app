import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/common/common_providers.dart';
import 'package:news_app/common_widgets/app_image.dart';
import 'package:news_app/common_widgets/common_widgets.dart';

import '../../../common/common_methods.dart';
import '../../../common/constants.dart';
import '../../authentication/repository/user_preferences.dart';
import '../providers/home_providers.dart';

class CheckAgainWidget extends HookConsumerWidget {
  const CheckAgainWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppImage(
            'assets/images/no_bookmarks.png',
            height: 250,
            width: 250,
          ),
          const Text('You have no favourites'),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              ref.read(isStarredProvider.notifier).update((state) => true);

              ref.invalidate(homeOffsetProvider);
              ref.invalidate(homeOrderProvider);
              ref.invalidate(homeSortDirectionProvider);
              ref.invalidate(homeIsShowReadProvider);

              final isDemoUser =
                  ref.read(userPrefsProvider).getIsDemo() ?? false;
              if (isDemoUser) {
                ref
                    .read(homeFeedProvider.notifier)
                    .fetchDemoEntries(context)
                    .then((_) {
                  ref.read(homeFeedProvider.notifier).starredDemoEntries();
                });
              } else {
                isLoading.value = true;

                ref
                    .refresh(homeFeedProvider.notifier)
                    .fetchEntries(context)
                    .then(
                      (_) => isLoading.value = false,
                    );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorRed,
            ),
            child: isLoading.value
                ? const CircularLoading()
                : const Text('Check Again'),
          ),
          const SizedBox(height: 10),
          TextBarButton(
            text: 'Home',
            textColor: colorRed,
            onTap: () {
              if (ref.read(emptyStateDisableProvider)) {}
              ref.read(refreshProvider).refreshAllMain(context);
            },
          ),
        ],
      ),
    );
  }
}
