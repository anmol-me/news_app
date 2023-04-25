import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/common/common_providers.dart';
import 'package:news_app/common/common_widgets.dart';
import 'package:news_app/features/home/widgets/home_refresh_button.dart';

import '../../../common/common_methods.dart';
import '../../../common/constants.dart';
import '../providers/home_providers.dart';
import '../screens/home_feed_screen.dart';

class CheckAgainWidget extends ConsumerWidget {
  const CheckAgainWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('You have no favourites'),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              ref.read(isStarredProvider.notifier).update((state) => true);

              ref.invalidate(homeOffsetProvider);
              ref.invalidate(homeOrderProvider);
              ref.invalidate(homeSortDirectionProvider);
              ref.invalidate(homeIsShowReadProvider);

              ref
                  .read(homePageLoadingProvider.notifier)
                  .update((state) => false);
              context.pushNamed(HomeFeedScreen.routeNamed);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorRed,
            ),
            child: const Text('Check Again'),
          ),
          const SizedBox(height: 10),
          TextBarButton(
            text: 'Home',
            textColor: colorRed,
            onTap: () {
              if (ref.read(emptyStateDisableProvider)) {

              }
              ref.read(refreshProvider).refreshAllMain(context);
            },
          ),
        ],
      ),
    );
  }
}
