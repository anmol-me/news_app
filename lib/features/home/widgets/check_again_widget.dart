import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/constants.dart';
import '../../../common/enums.dart';
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
              final isStarredController = ref.read(isStarredProvider.notifier);
              final isLoadingPageController =
                  ref.read(homePageLoadingProvider.notifier);

              isStarredController.update((state) => true);
              ref.refresh(homeOffsetProvider.notifier).update((state) => 0);

              ref.refresh(homeOrderProvider.notifier).update(
                    (state) => OrderBy.publishedAt,
                  );
              ref.refresh(homeSortDirectionProvider.notifier).update(
                    (state) => Sort.descending,
                  );
              ref.refresh(homeIsShowReadProvider.notifier).update((state) => false);

              isLoadingPageController.update((state) => false);
              Navigator.of(context).pushNamed(HomeFeedScreen.routeNamed);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorRed,
            ),
            child: const Text('Check Again'),
          ),
        ],
      ),
    );
  }
}
