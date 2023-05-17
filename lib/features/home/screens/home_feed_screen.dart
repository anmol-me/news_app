import 'dart:async';

export '../../../common_widgets/build_expansion_widget.dart';

import '../../../common/common_methods.dart';
import '../../../common/common_providers.dart';
import '../../../common_widgets/build_popup_menu_button.dart';
import '../../../common_widgets/build_top_bar.dart';
import '../../../common_widgets/build_expansion_widget.dart';

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
import '../widgets/home_refresh_button.dart';
import '../widgets/welcome_view_widget.dart';
import '../repository/home_methods.dart';

class HomeFeedScreen extends ConsumerStatefulWidget {
  static const routeNamed = '/home-feed-screen';

  const HomeFeedScreen({super.key});

  @override
  ConsumerState createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen> {
  final scrollController = ScrollController();

  @override
  initState() {
    super.initState();
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

      if (!isDemoUser) {
        emptyStateDisableController.update((state) => false);
      } else if (next.isEmpty && !isStarred && isLoadingHomePage) {
        emptyStateDisableController.update((state) => true);
      } else if (next.isEmpty && isStarred) {
        emptyStateDisableController.update((state) => false);
        disableFilterController.update((state) => true);
      } else {
        emptyStateDisableController.update((state) => false);
        disableFilterController.update((state) => false);
      }
    });

    ref.listen<List>(categoryNotifierProvider, (previous, next) {
      if (next.isNotEmpty) {
        ref.read(emptyStateDisableProvider.notifier).update((state) => false);
      }
    });

    /// Providers ///

    final newsNotifier = ref.watch(homeFeedProvider);

    final sortAs = ref.watch(homeSortDirectionProvider);
    final isShowRead = ref.watch(homeIsShowReadProvider);

    final canGoToNextPage = ref.watch(homeIsNextProvider);
    final canGoToPreviousPage = ref.watch(homeOffsetProvider) != 0;

    final homeMethods = ref.watch(homeMethodsProvider(context));
    final emptyStateDisable = ref.watch(emptyStateDisableProvider);
    final disableFilter = ref.watch(disableFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isStarred ? 'Starred' : 'Feeds'),
        actions: [
          isDemoUser
              ? newsNotifier.isNotEmpty
                  ? TextButton(
                      onPressed: () => ref.refresh(homeFeedProvider),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: colorRed,
                        ),
                      ),
                    )
                  : const SizedBox.shrink()
              : const SizedBox.shrink(),
          if (emptyStateDisable)
            const HomeRefreshButton()
          else
            const SizedBox.shrink(),
          if (emptyStateDisable)
            IconButton(
              onPressed: null,
              icon: Icon(
                Icons.search,
                color: colorDisabled,
              ),
            )
          else
            IconButton(
              onPressed: () => context.pushNamed(SearchScreen.routeNamed),
              icon: const Icon(Icons.search),
            ),
          emptyStateDisable || disableFilter
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
      drawer: const AppDrawer(),
      onDrawerChanged: (isOpened) {
        ref.read(isHomeDrawerOpened.notifier).update((state) => isOpened);
      },
      body: Column(
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
                onRefresh: () =>
                    ref.read(refreshProvider).refreshAllMain(context),
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

                                return buildExpansionWidget(
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
    );
  }
}
