import 'dart:async';

export '../../../common_widgets/build_title_expansion_widget.dart';

import 'package:news_app/components/clear_button.dart';
import 'package:news_app/features/home/widgets/home_refresh_button.dart';

import '../../../common/common_methods.dart';
import '../../../common/common_providers.dart';
import '../../../common_widgets/build_popup_menu_button.dart';
import '../../../common_widgets/build_top_bar.dart';
import '../../../common_widgets/build_title_expansion_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:news_app/features/search/screens/search_screen.dart';
import '../../../common_widgets/common_widgets.dart';
import '../../authentication/repository/user_preferences.dart';
import '../../category/repository/category_repo.dart';
import '../providers/home_providers.dart';

import 'package:news_app/common/constants.dart';
import 'package:news_app/features/app_bar/app_drawer.dart';

import '../widgets/check_again_widget.dart';
import '../widgets/welcome_view_widget.dart';
import '../repository/home_methods.dart';

class HomeWebScreen extends ConsumerStatefulWidget {
  static const routeNamed = '/home-web-screen';

  const HomeWebScreen({super.key});

  @override
  ConsumerState createState() => _HomeWebScreenState();
}

class _HomeWebScreenState extends ConsumerState<HomeWebScreen> {
  final scrollController = ScrollController();

  @override
  initState() {
    super.initState();
    Future.delayed(Duration.zero).then(
      (_) =>
          ref.read(emptyStateDisableProvider.notifier).update((state) => false),
    );

    Timer(const Duration(seconds: 20), () => FlutterNativeSplash.remove());

    final isDemoPref = ref.read(userPrefsProvider).getIsDemo() ?? false;
    if (isDemoPref) {
      ref.read(homeFeedProvider.notifier).fetchDemoEntries(context);
      return;
    }

    final isLoadingHomePageController =
        ref.read(homePageLoadingProvider.notifier);

    Future.delayed(Duration.zero).then(
      (_) => isLoadingHomePageController.update((state) => true),
    );

    ref.read(homeFeedProvider.notifier).fetchEntries(context).then(
      (_) {
        FlutterNativeSplash.remove();
        return isLoadingHomePageController.update((state) => false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDemoUser = ref.watch(userPrefsProvider).getIsDemo() ?? false;
    final isLoadingHomePage = ref.watch(homePageLoadingProvider);
    final isStarred = ref.watch(isStarredProvider);

    ref.listen<List>(homeFeedProvider, (previous, next) {
      final emptyStateDisableController =
          ref.read(emptyStateDisableProvider.notifier);

      final disableFilterController = ref.read(disableFilterProvider.notifier);

      final isLoadingHomePageController =
          ref.read(homePageLoadingProvider.notifier);

      if (!isDemoUser) {
        emptyStateDisableController.update((state) => false);
      } else if (next.isEmpty && !isStarred && !isLoadingHomePage) {
        emptyStateDisableController.update((state) => true);
      } else if (next.isEmpty && isStarred) {
        emptyStateDisableController.update((state) => false);
        disableFilterController.update((state) => true);
      } else {
        emptyStateDisableController.update((state) => false);
        disableFilterController.update((state) => false);
        isLoadingHomePageController.update((state) => false);
      }
    });

    ref.listen<List>(categoryNotifierProvider, (previous, next) {
      if (next.isNotEmpty) {
        ref.read(emptyStateDisableProvider.notifier).update((state) => false);
      }
    });

    final currentWidth = MediaQuery.of(context).size.width;

    /// Providers ///

    final newsNotifier = ref.watch(homeFeedProvider);

    final sortAs = ref.watch(homeSortDirectionProvider);
    final isShowRead = ref.watch(homeIsShowReadProvider);

    final canGoToNextPage = ref.watch(homeIsNextProvider);
    final canGoToPreviousPage = ref.watch(homeOffsetProvider) != 0;

    final homeMethods = ref.watch(homeMethodsProvider(context));
    final emptyStateDisable = ref.watch(emptyStateDisableProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isStarred ? 'Starred' : 'Feeds'),
        actions: [
          isDemoUser
              ? newsNotifier.isNotEmpty
                  ? const HomeClearButton()
                  : const SizedBox.shrink()
              : const SizedBox.shrink(),
          if (emptyStateDisable)
            const HomeRefreshButton()
          else
            const SizedBox.shrink(),
          emptyStateDisable
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(
                    Icons.search,
                    color: colorDisabled,
                  ),
                )
              : IconButton(
                  onPressed: () => context.pushNamed(SearchScreen.routeNamed),
                  icon: const Icon(Icons.search),
                ),
          emptyStateDisable
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.filter_alt, color: colorDisabled),
                )
              : BuildPopupMenuButton(
                  isShowRead: isShowRead,
                  sort: sortAs,
                  sortFunction: homeMethods.sortFunction,
                  readFunction: homeMethods.readFunction,
                ),
        ],
      ),
      drawer: currentWidth <= 650 ? const AppDrawer() : null,
      body: Row(
        children: [
          if (currentWidth > 650) const AppDrawer(),
          if (currentWidth > 650) const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                // Top Column Bar
                newsNotifier.isEmpty
                    ? const SizedBox.shrink()
                    : buildTopBar(
                        isLoadingHomePage,
                        canGoToPreviousPage,
                        homeMethods.previousFunction,
                        canGoToNextPage,
                        homeMethods.nextFunction,
                        isDemoUser,
                        ref,
                      ),
                if (isLoadingHomePage)
                  const LinearLoader()
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () {
                        return ref
                            .read(refreshProvider)
                            .refreshAllMain(context);
                      },
                      color: colorRed,
                      child: newsNotifier.isEmpty && isStarred
                          ? const CheckAgainWidget()
                          : newsNotifier.isEmpty
                              ? const WelcomeViewWidget()
                              : Scrollbar(
                                  controller: scrollController,
                                  child: ListView.builder(
                                    controller: scrollController,
                                    shrinkWrap: true,
                                    itemCount: newsNotifier.length,
                                    itemBuilder: (context, index) {
                                      final newsItem = newsNotifier[index];

                                      return buildTileExpansionWidget(
                                        'home',
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
