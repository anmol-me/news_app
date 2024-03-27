import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/common_widgets/common_widgets.dart';
import 'package:news_app/components/clear_button.dart';
import 'package:news_app/features/category/repository/category_repo.dart';
import 'package:news_app/features/app_bar/app_drawer.dart';

import '../../../common/constants.dart';
import '../../../common/enums.dart';
import '../../../common_widgets/app_image.dart';
import '../../../common_widgets/build_popup_menu_button.dart';
import '../../../common_widgets/build_top_bar.dart';
import '../../../components/app_back_button.dart';
import '../../authentication/repository/user_preferences.dart';
import '../../home/screens/home_feed_screen.dart';
import '../../search/screens/search_screen.dart';

/// Providers
final catSortProvider = StateProvider<Sort>((ref) => Sort.descending);

final isShowReadCatProvider = StateProvider<bool>((ref) => false);

final catPageHandlerProvider = StateProvider<int>((ref) => 0);

final catMaxPagesProvider = FutureProvider.family<int, int>((ref, id) {
  final totalPages =
      ref.watch(categoryNotifierProvider.notifier).catTotalPage(id);
  return totalPages;
});

final catIsNextProvider = StateProvider.family<bool, int>(
  (ref, id) {
    final maxPages = ref.watch(catMaxPagesProvider(id)).value;

    final catPageHandler = ref.watch(catPageHandlerProvider);

    final currentPage = 1 + catPageHandler;

    if (maxPages == currentPage) {
      return false;
    } else {
      return true;
    }
  },
);

// final GlobalKey<ScaffoldState> drawerScaffoldKey = GlobalKey<ScaffoldState>();

/// Widgets
class CategoryScreen extends HookConsumerWidget {
  static const routeNamed = '/category-screen';

  final int catId;
  final String catTitle;
  final bool isBackButton;

  const CategoryScreen({
    super.key,
    required this.catId,
    required this.catTitle,
    required this.isBackButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawerKey = useMemoized(GlobalKey<ScaffoldState>.new, const []);

    final isCatLoading = ref.watch(isCatLoadingProvider);
    final isCatLoadingController = ref.watch(isCatLoadingProvider.notifier);

    final catSort = ref.watch(catSortProvider);
    final isShowReadCat = ref.watch(isShowReadCatProvider);

    useEffect(
      () {
        final isDemoPref = ref.read(userPrefsProvider).getIsDemo() ?? false;
        if (isDemoPref) {
          Future.delayed(Duration.zero).then(
            (_) => ref
                .read(categoryNotifierProvider.notifier)
                .fetchDemoCategoryEntries(catId, context),
          );
          return;
        }

        Future.delayed(Duration.zero)
            .then((_) => isCatLoadingController.update((state) => true));

        ref
            .read(categoryNotifierProvider.notifier)
            .fetchCategoryEntries(catId, context)
            .then((_) => isCatLoadingController.update((state) => false));

        return null;
      },
      [],
    );

    // For Fav and Read Buttons
    final catNewsNotifier = ref.watch(categoryNotifierProvider);

    final canGoToNextPage = ref.watch(catIsNextProvider(catId));
    final canGoToPreviousPage = ref.watch(catOffsetProvider) != 0;

    final categoryNotifier = ref.watch(categoryNotifierProvider.notifier);

    final isDemoUser = ref.watch(userPrefsProvider).getIsDemo() ?? false;

    final scrollController = useScrollController();
    final isMobile = MediaQuery.sizeOf(context).width <= 650;

    return Scaffold(
      key: drawerKey,
      appBar: AppBar(
        title: Text(catTitle),
        leading: isBackButton || !isMobile
            ? const AppBackButton(controller: false)
            : IconButton(
                onPressed: () {
                  if (drawerKey.currentState!.isDrawerOpen) {
                    Navigator.pop(context);
                  } else {
                    drawerKey.currentState!.openDrawer();
                  }
                },
                icon: const Icon(Icons.menu),
              ),
        actions: [
          isDemoUser
              ? CategoryClearButton(catId: catId)
              : const SizedBox.shrink(),
          IconButton(
            onPressed: () => context.pushNamed(SearchScreen.routeNamed),
            icon: const Icon(Icons.search),
          ),
          BuildPopupMenuButton(
            isShowRead: isShowReadCat,
            sort: catSort,
            sortFunction: () =>
                categoryNotifier.sortCatFunction(catId, context),
            readFunction: () =>
                categoryNotifier.readCatFunction(catId, context),
          ),
        ],
      ),
      drawer: isMobile ? const AppDrawer() : null,
      body: Row(
        children: [
          if (!isMobile) const AppDrawer(),
          Expanded(
            child: Column(
              children: [
                // Top Column
                buildTopBar(
                  isCatLoading,
                  canGoToPreviousPage,
                  () => categoryNotifier.previous(catId, context),
                  canGoToNextPage,
                  () => categoryNotifier.next(catId, context),
                  isDemoUser,
                  ref,
                ),

                // DISPLAY BODY //
                if (isCatLoading || isCatLoading)
                  const LinearLoader()
                else if (catNewsNotifier.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AppImage(
                            'assets/images/items_not_found.png',
                            height: 250,
                            width: 250,
                          ),
                          Text(Message.categoryEmpty.value),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => categoryNotifier.refresh(catId, context),
                      color: colorRed,
                      child: Scrollbar(
                        controller: scrollController,
                        child: ListView.builder(
                          controller: scrollController,
                          shrinkWrap: true,
                          itemCount: catNewsNotifier.length,
                          itemBuilder: (context, index) {
                            final newsItem = catNewsNotifier[index];

                            return buildTileExpansionWidget(
                              'category',
                              newsItem,
                              context,
                              ref,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
