import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/common/common_providers.dart';

import '../../../common/enums.dart';
import '../../authentication/repository/user_preferences.dart';
import '../providers/home_providers.dart';

final homeMethodsProvider = Provider.family<HomeMethods, BuildContext>(
  (ref, context) => HomeMethods(
    ref: ref,
    context: context,
    isLoadingHomePageController: ref.watch(homePageLoadingProvider.notifier),
  ),
);

class HomeMethods {
  final Ref ref;
  final BuildContext context;
  final StateController<bool> isLoadingHomePageController;

  HomeMethods({
    required this.ref,
    required this.context,
    required this.isLoadingHomePageController,
  });

  void nextFunction() {
    isLoadingHomePageController.update((state) => true);

    ref.read(homeCurrentPageProvider.notifier).update((state) => state += 1);

    ref.read(homeOffsetProvider.notifier).update((state) => state += 100);

    ref.read(homeFeedProvider.notifier).fetchEntries(context).then(
          (_) => isLoadingHomePageController.update((state) => false),
        );
  }

  void previousFunction() {
    isLoadingHomePageController.update((state) => true);

    ref.read(homeCurrentPageProvider.notifier).update(
          (state) => state != 1 ? state -= 1 : 1,
        );

    ref.read(homeOffsetProvider.notifier).update((state) => state -= 100);

    ref.read(homeFeedProvider.notifier).fetchEntries(context).then(
          (_) => isLoadingHomePageController.update((state) => false),
        );
  }

  void sortFunction() {
    final sortAs = ref.read(homeSortDirectionProvider);
    final sortDirectionController =
        ref.read(homeSortDirectionProvider.notifier);

    final isDemoPref = ref.read(userPrefsProvider).getIsDemo() ?? false;
    if (!isDemoPref) {
      isLoadingHomePageController.update((state) => true);
      ref.refresh(homeOffsetProvider.notifier).update((state) => 0);

      if (sortAs == Sort.ascending) {
        sortDirectionController.update((state) => state = Sort.descending);
      } else if (sortAs == Sort.descending) {
        sortDirectionController.update((state) => state = Sort.ascending);
      } else {
        sortDirectionController.update((state) => state = Sort.descending);
      }

      ref.refresh(homeFeedProvider.notifier).fetchEntries(context).then(
            (_) => isLoadingHomePageController.update((state) => false),
          );
    } else {
      // Demo
      ref.read(homeFeedProvider.notifier).sortEntries();
    }
  }

  void readFunction() {
    final isDemoPref = ref.read(userPrefsProvider).getIsDemo() ?? false;
    if (!isDemoPref) {
      isLoadingHomePageController.update((state) => true);

      ref
          .read(homeIsShowReadProvider.notifier)
          .update((state) => state = !state);

      ref.refresh(homeFeedProvider.notifier).fetchEntries(context).then(
            (_) => isLoadingHomePageController.update((state) => false),
          );
    } else {
      // Demo
      ref.read(homeFeedProvider.notifier).fetchDemoEntries(context);
      ref.read(homeFeedProvider).where((e) => e.status == Status.read);
    }
  }

  void refreshHomeProviders() {
    ref.invalidate(emptyStateDisableProvider);
    ref.invalidate(disableFilterProvider);
    ref.invalidate(isStarredProvider);
    ref.invalidate(homeSortDirectionProvider);
    ref.invalidate(homeIsShowReadProvider);
    ref.invalidate(homeIsNextProvider);
    ref.invalidate(homeOffsetProvider);
    ref.invalidate(homeFeedProvider);
  }
}
