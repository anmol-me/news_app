import 'dart:async';

export '../../../common_widgets/build_expansion_widget.dart';
import 'package:go_router/go_router.dart';

import '../../../common/common_methods.dart';
import '../../../common_widgets/build_popup_menu_button.dart';
import '../../../common_widgets/build_top_bar.dart';
import '../../../common_widgets/build_expansion_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

import 'package:news_app/features/search/screens/search_screen.dart';
import '../../../common/common_widgets.dart';
import '../../../common/enums.dart';
import '../../authentication/repository/auth_repo.dart';
import '../providers/home_providers.dart';
import '../repository/home_feed_repo.dart';
import 'package:fade_shimmer/fade_shimmer.dart';

import 'package:news_app/common/constants.dart';
import 'package:news_app/features/app_bar/app_drawer.dart';

import '../widgets/check_again_widget.dart';
import '../widgets/welcome_view_widget.dart';
import '../repository/home_methods.dart';


class HomeFeedScreen extends ConsumerStatefulWidget {
  static const routeNamed = '/home-feed-screen';

  const HomeFeedScreen({super.key});

  @override
  ConsumerState createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen> {
  @override
  initState() {
    super.initState();
    Timer(const Duration(seconds: 20), () => FlutterNativeSplash.remove());

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
    final scrollController = ScrollController();

    /// Providers ///
    // log('${ref.read(categoryListNotifierFuture(context)).whenData((value) => value).value}');

    // final catNames = ref.watch(categoryNamesProvider(context)).value;
    // List<Tab>? categoryNames = catNames?.map((e) => e).toList() ?? [Tab(text: 'Wait')];

    // log(categoryNames.toString());

    final isLoadingHomePage = ref.watch(homePageLoadingProvider);
    final isLoadingHomePageController =
        ref.watch(homePageLoadingProvider.notifier);

    final newsNotifier = ref.watch(homeFeedProvider);
    final newsNotifierController = ref.watch(homeFeedProvider.notifier);

    final isStarred = ref.watch(isStarredProvider);
    final sortAs = ref.watch(homeSortDirectionProvider);
    final isShowRead = ref.watch(homeIsShowReadProvider);

    // final isSelected = ref.watch(homeIsSelectedProvider);
    // final isSelectedController = ref.read(homeIsSelectedProvider.notifier);

    final canGoToNextPage = ref.watch(homeIsNextProvider);
    final canGoToPreviousPage = ref.watch(homeOffsetProvider) != 0;

    final homeMethods = ref.watch(homeMethodsProvider(context));

    return Scaffold(
      appBar: AppBar(
        title: Text(isStarred ? 'Starred' : 'Feeds'),
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed(SearchScreen.routeNamed);

              /// Todo: Nav
              // Navigator.of(context).pushNamed(SearchScreen.routeNamed);
            },
            icon: const Icon(Icons.search),
          ),

          /// Todo: Temporary Clear Button
          IconButton(
            onPressed: () => ref.refresh(homeFeedProvider).clear(),
            icon: Icon(
              Icons.clear,
              color: colorRed,
            ),
          ),
          IconButton(
            onPressed: () => ref.refresh(userPrefsProvider).clearPrefs(),
            icon: Icon(
              Icons.delete,
              color: colorRed,
            ),
          ),
          buildPopupMenuButton(
            ref: ref,
            isShowRead: isShowRead,
            sort: sortAs,
            sortFunction: homeMethods.sortFunction,
            readFunction: homeMethods.readFunction,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      onDrawerChanged: (isOpened) {
        print('Drawer Checker: $isOpened');
        ref.read(isHomeDrawerOpened.notifier).update((state) => isOpened);
      },
      body: Column(
        children: [
          // Sidebar
          // Expanded(
          //   child: const ResponsiveVisibility(
          //     hiddenWhen: [Condition.smallerThan(name: DESKTOP)],
          //     child: AppDrawer(),
          //   ),
          // ),

          // Top Column Bar
          newsNotifier.isEmpty
              ? const SizedBox.shrink()
              : buildTopBar(
                  isLoadingHomePage,
                  canGoToPreviousPage,
                  homeMethods.previousFunction,
                  canGoToNextPage,
                  homeMethods.nextFunction,
                  ref,
                ),
          if (isLoadingHomePage)
            const LinearLoader()
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref
                    .read(refreshProvider)
                    .refreshAllMain(context),

                //     refreshAll(
                //   // Navigator.of(context),
                //   ref,
                //   context,
                //   isLoadingHomePageController,
                // ),
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
                                final dateTime = getDate(newsItem);

                                return buildExpansionWidget(
                                  newsItem,
                                  dateTime,
                                  context,
                                  newsNotifierController,
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

/// ///////////////////////////////////////////////////////////////////////////////////////

// extension Extract on String {
//   String? extractImage() {
//     if (contains('img')) {
//       return html_parser
//               .parse(this)
//               .getElementsByTagName('img')[0]
//               .attributes['src'] ??
//           '';
//     } else {
//       return '';
//     }
//   }
// }

/*

    '${HtmlParser.parse(
          "<figure>\n      <img alt=\"\" src=\"https://cdn.vox-cdn.com/thumbor/0eAXXCxHnTICFIF3nz6b8nJwYIA=/8x0:868x573/1310x873/cdn.vox-cdn.com/uploads/chorus_image/image/71292460/tmobile_spacex_satellite.5.png\" loading=\"lazy\"/>\n        <figcaption><em>There are a few companies that want to keep you connected when you’re in remote areas. </em> | Image: SpaceX</figcaption>\n    </figure>\n\n  <p>On Thursday, Elon Musk got on stage with T-Mobile CEO Mike Sievert to announce that SpaceX is working with the carrier to <a href=\"https://www.theverge.com/2022/8/25/23320722/spacex-starlink-t-mobile-satellite-internet-mobile-messaging\" rel=\"noopener noreferrer\" target=\"_blank\" referrerpolicy=\"no-referrer\">completely eliminate cellular dead zones</a>. The companies claim that next-generation Starlink satellites, set to launch next year, will be able to communicate directly with phones, letting you text, make calls, and potentially stream video even when there are no cell towers nearby. What’s more, Musk promised all this is possible with phones that people are using today, without consumers having to buy any extra equipment.</p>\n<p>It’s a bold proclamation from the carrier — Verizon and AT&amp;T don’t offer anything like it. However, SpaceX and T-Mobile aren’t the only companies looking to use satellites to directly communicate with...</p>\n  <p>\n    <a href=\"https://www.theverge.com/2022/8/27/23324128/t-mobile-spacex-satellite-to-phone-technology-ast-lynk-industry-reactions-apple\" rel=\"noopener noreferrer\" target=\"_blank\" referrerpolicy=\"no-referrer\">Continue reading…</a>\n  </p>",
        ).getElementsByTagName('img')[0].attributes['src']}',

 */

/// For Grouped List View
/*
    List nowList = newsNotifier.where((element) {
      log(DateFormat('dd MMM yyyy').format(
        element.publishedTime,
      ).toString());

      log(DateFormat('dd MMM yyyy').format(
        DateTime.now(),
      ).toString());

      return DateFormat('dd MMM yyyy').format(
        element.publishedTime,
      ) == DateFormat('dd MMM yyyy').format(
        DateTime.now(),
      );
    }).toList();

    log('LENGth: ${nowList.length}');
 */
