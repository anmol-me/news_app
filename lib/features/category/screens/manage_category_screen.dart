import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:news_app/common_widgets/common_widgets.dart';
import '../../../common/constants.dart';
import '../../../common/enums.dart';
import '../../../common_widgets/app_image.dart';
import '../../../components/app_back_button.dart';
import '../../subscription/screens/add_subscription_screen.dart';
import '../repository/manage_category_repository.dart';
import 'edit_feed_screen.dart';

/// Providers
final isManageLoadingProvider = StateProvider((ref) => false);

final isManageProcessingProvider = StateProvider((ref) => false);

/// Widgets
class ManageCategoryScreen extends HookConsumerWidget {
  static const routeNamed = '/manage-category-screen';

  final int catListItemId;
  final String catListItemTitle;

  const ManageCategoryScreen({
    super.key,
    required this.catListItemId,
    required this.catListItemTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isManageLoading = ref.watch(isManageLoadingProvider);
    final isManageLoadingController =
        ref.watch(isManageLoadingProvider.notifier);

    final isManageProcessing = ref.watch(isManageProcessingProvider);
    final isManageProcessingController =
        ref.watch(isManageProcessingProvider.notifier);

    useEffect(
      () {
        Future.delayed(Duration.zero)
            .then((_) => isManageLoadingController.update((state) => true));

        ref
            .read(manageCateNotifierProvider.notifier)
            .fetchCategoryFeeds(context, catListItemId)
            .then((_) => isManageLoadingController.update((state) => false));

        return null;
      },
      [],
    );

    final isManageNotifier = ref.watch(manageCateNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(catListItemTitle),
        leading: AppBackButton(
          controller: isManageProcessing,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final subListener = ref.listenManual(
                  selectedCategoryProvider, (previous, next) {});
              ref.read(selectedCategoryProvider.notifier).update(
                    (state) => catListItemTitle,
                  );

              isManageLoading || isManageProcessing
                  ? null
                  : await context.pushNamed(AddSubscription.routeNamed);

              subListener.close();
            },
            icon: Icon(
              Icons.add,
              color: isManageLoading || isManageProcessing
                  ? colorDisabled
                  : colorRed,
            ),
          ),
        ],
      ),
      body: isManageLoading
          ? const LinearLoader()
          : Stack(
              children: [
                if (!isManageProcessing && isManageNotifier.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppImage(
                          'assets/images/items_not_found.png',
                          height: 250,
                          width: 250,
                        ),
                        Text(Message.feedEmpty.value),
                      ],
                    ),
                  )
                else if (isManageProcessing)
                  const LinearLoader()
                else
                  Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: isManageNotifier.length,
                          itemBuilder: (listContext, i) {
                            final item = isManageNotifier[i];

                            return ListTile(
                              title: Text(item.title),
                              trailing: Wrap(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      context.pushNamed(
                                        EditFeedScreen.routeNamed,
                                        queryParameters: {
                                          'feedTitle': item.title,
                                          'feedId': item.id.toString(),
                                          'catId': catListItemId.toString(),
                                        },
                                        extra: listContext,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Theme.of(listContext)
                                          .colorScheme
                                          .error,
                                    ),
                                    onPressed: () {
                                      isManageProcessingController.update(
                                        (state) => true,
                                      );

                                      ref
                                          .read(manageCateNotifierProvider
                                              .notifier)
                                          .deleteCatFeed(
                                            context,
                                            item,
                                          )
                                          .then(
                                            (_) => isManageProcessingController
                                                .update((state) => false),
                                          );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
    );
  }
}
