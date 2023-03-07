// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer' show log;
//
// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:html/parser.dart' as html_parser;
// import 'package:flutter_native_splash/flutter_native_splash.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:jiffy/jiffy.dart';
//
// import 'package:news_app/features/search/screens/search_screen.dart';
// import 'package:news_app/features/details/screens/news_details_screen.dart';
// import '../../../common/enums.dart';
// import '../providers/home_providers.dart';
// import '../repository/home_feed_repo.dart';
// import 'package:fade_shimmer/fade_shimmer.dart';
//
// import 'package:news_app/common/constants.dart';
// import 'package:news_app/models/news.dart';
// import 'package:news_app/widgets/app_drawer.dart';
// import '../widgets/expansion_widget.dart';
//
// // TODO: 2 Loading Controllers
//
// class HomeFeedScreen extends ConsumerStatefulWidget {
//   static const routeNamed = '/home-feed-screen';
//
//   const HomeFeedScreen({super.key});
//
//   @override
//   ConsumerState createState() => _HomeFeedScreenState();
// }
//
// class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen> {
// //
// //
// // class HomeFeedScreen extends HookConsumerWidget {
// //   static const routeNamed = '/home-feed-screen';
// //
// //   const HomeFeedScreen({super.key});
//
//   @override
//   initState() {
//     super.initState();
//     Timer(const Duration(seconds: 20), () => FlutterNativeSplash.remove());
//
//     final isLoadingNewsController =
//     ref.read(homeIsLoadingNewsProvider.notifier);
//
//     Future.delayed(Duration.zero).then(
//           (value) => isLoadingNewsController.update((state) => true),
//     );
//
//     ref
//         .read(homeFeedProvider.notifier)
//         .fetchEntries(context)
//         .then(
//           (_) => isLoadingNewsController.update((state) => false),
//     )
//         .then(
//           (_) => FlutterNativeSplash.remove(),
//     );
//   }
//
//   String getDate(newsItem) {
//     final dateFormatted = DateFormat('dd MMM yyyy').format(
//       newsItem.publishedTime,
//     );
//
//     final now = DateFormat('dd MMM yyyy').format(
//       DateTime.now(),
//     );
//
//     final yesterday = DateFormat('dd MMM yyyy').format(
//       DateTime.now().subtract(const Duration(days: 1)),
//     );
//
//     final twoDaysAgo = DateFormat('dd MMM yyyy').format(
//       DateTime.now().subtract(const Duration(days: 2)),
//     );
//
//     final todayTime = Jiffy(
//       newsItem.publishedTime,
//     ).fromNow().toString();
//
//     var dateUsed = dateFormatted == now
//         ? todayTime
//         : dateFormatted == yesterday
//         ? 'Yesterday'
//         : dateFormatted == twoDaysAgo
//         ? '2 days ago'
//         : dateFormatted;
//
//     return dateUsed;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // log('************ HOME FEED SCREEN *****************');
//
//     final isLoadingNews = ref.watch(homeIsLoadingNewsProvider);
//
//     // log('${ref.read(categoryListNotifierFuture(context)).whenData((value) => value).value}');
//
//     // final catNames = ref.watch(categoryNamesProvider(context)).value;
//     // List<Tab>? categoryNames = catNames?.map((e) => e).toList() ?? [Tab(text: 'Wait')];
//
//     // log(categoryNames.toString());
//
//     final isLoadingPage = ref.watch(homeIsLoadingPageProvider);
//     final isLoadingPageController = ref.watch(homeIsLoadingPageProvider.state);
//
//     final isStarred = ref.watch(homeIsStarredProvider);
//
//     var newsNotifier = ref.watch(homeFeedProvider);
//     final newsNotifierController = ref.watch(homeFeedProvider.notifier);
//
//     final sort = ref.watch(homeSortDirectionProvider);
//     final sortDirectionController = ref.watch(homeSortDirectionProvider.state);
//
//     final isShowRead = ref.watch(homeIsShowReadProvider);
//     final isShowReadController = ref.watch(homeIsShowReadProvider.state);
//
//     // final isSelected = ref.watch(homeIsSelectedProvider);
//     // final isSelectedController = ref.read(homeIsSelectedProvider.notifier);
//
//     final canGoToNextPage = ref.watch(homeIsNextProvider);
//     final canGoToPreviousPage = ref.watch(homeOffsetProvider) != 0;
//
//     void sortFunction() {
//       isLoadingPageController.update((state) => true);
//       ref.refresh(homeOffsetProvider);
//
//       if (sort == Sort.ascending) {
//         sortDirectionController.update((state) => state = Sort.descending);
//       } else if (sort == Sort.descending) {
//         sortDirectionController.update((state) => state = Sort.ascending);
//       } else {
//         sortDirectionController.update((state) => state = Sort.descending);
//       }
//
//       ref.refresh(homeFeedProvider.notifier).fetchEntries(context).then(
//             (value) => isLoadingPageController.update((state) => false),
//       );
//     }
//
//     void previous() {
//       isLoadingPageController.update((state) => true);
//
//       ref.read(homePageHandlerProvider.notifier).update((state) {
//         if (state != 1) {
//           return state -= 1;
//         } else {
//           return 0;
//         }
//       });
//
//       ref.read(homeOffsetProvider.notifier).update((state) => state -= 100);
//       // log('PREVIOUS-OFFSET: ${ref.watch(offsetProvider)}');
//
//       ref.read(homeFeedProvider.notifier).fetchEntries(context).then(
//             (_) => isLoadingPageController.update((state) => false),
//       );
//     }
//
//     void next() {
//       isLoadingPageController.update((state) => true);
//
//       ref.read(homePageHandlerProvider.notifier).update((state) => state += 1);
//
//       ref.read(homeOffsetProvider.notifier).update((state) => state += 100);
//
//       ref.read(homeFeedProvider.notifier).fetchEntries(context).then(
//             (_) {
//           // log(newsNotifier.length.toString());
//           isLoadingPageController.update((state) => false);
//         },
//       );
//     }
//
//     Future<void> refresh() async {
//       isLoadingPageController.update((state) => true);
//
//       ref.refresh(homeOffsetProvider);
//       ref.refresh(homeSortDirectionProvider);
//       ref.refresh(homeIsStarredProvider);
//       ref.refresh(homeIsShowReadProvider);
//
//       ref.refresh(homeFeedProvider.notifier).fetchEntries(context).then(
//             (value) => isLoadingPageController.update((state) => false),
//       );
//     }
//
//     void read() {
//       isLoadingPageController.update((state) => true);
//
//       isShowReadController.update((state) => state = !state);
//       ref.refresh(homeFeedProvider.notifier).fetchEntries(context).then(
//             (value) => isLoadingPageController.update((state) => false),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Feeds'),
//         actions: [
//           IconButton(
//             onPressed: () {
//               Navigator.of(context).pushNamed(SearchScreen.routeNamed);
//             },
//             icon: const Icon(Icons.search),
//           ),
//           buildPopupMenuButton(
//             isShowRead,
//             sort,
//             sortFunction,
//             read,
//           ),
//         ],
//       ),
//       drawer: const AppDrawer(),
//
//       /// ///////////////////////////////////////////////////////////////////////////////////////
//       // BODY //
//
//       body: Column(
//         children: [
//           // Top Column
//           buildTopColumn(
//             isLoadingPage,
//             canGoToPreviousPage,
//             previous,
//             canGoToNextPage,
//             next,
//           ),
//
//           /// ///////////////////////////////////////////////////////////////////////////////////////
//           // DISPLAY BODY //
//
//           if (isLoadingNews || isLoadingPage)
//           // const LinearLoader()
//             const Text('Loading...')
//           else
//             Expanded(
//               child: RefreshIndicator(
//                 onRefresh: refresh,
//                 color: colorRed,
//                 child: Scrollbar(
//                   child: newsNotifier.isEmpty && isStarred
//                       ? const Text('No Favourites')
//                       : newsNotifier.isEmpty
//                       ? const Text('List is Empty')
//                       : ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: newsNotifier.length,
//                     itemBuilder: (context, index) {
//                       final newsItem = newsNotifier[index];
//                       final dateTime = getDate(newsItem);
//
//                       String? titleText = newsItem.titleText;
//                       final decodedText =
//                       utf8.decode(titleText.runes.toList());
//
//                       return Padding(
//                         padding: const EdgeInsets.only(
//                           top: 5,
//                           bottom: 5,
//                           left: 16,
//                           right: 16,
//                         ),
//                         child: Column(
//                           crossAxisAlignment:
//                           CrossAxisAlignment.start,
//                           children: [
//                             ExpansionWidget(
//                               topSection: topSectionRow(
//                                 newsItem,
//                                 dateTime,
//                               ),
//                               titleSection: Padding(
//                                 padding: const EdgeInsets.only(
//                                   top: 8.0,
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     ClipRRect(
//                                       borderRadius:
//                                       BorderRadius.circular(
//                                         2,
//                                       ),
//                                       child: CachedNetworkImage(
//                                         imageUrl: newsItem.imageUrl,
//                                         height: 90,
//                                         width: 120,
//                                         fit: BoxFit.cover,
//                                         placeholder: (context, url) {
//                                           return Center(
//                                             child:
//                                             CircularProgressIndicator(
//                                               color: colorRed,
//                                               strokeWidth: 1,
//                                             ),
//                                           );
//                                         },
//                                         errorWidget: (
//                                             context,
//                                             url,
//                                             error,
//                                             ) =>
//                                             Image.network(
//                                               ErrorString.image.value,
//                                               height: 90,
//                                               width: 120,
//                                               fit: BoxFit.cover,
//                                             ),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 10),
//                                     Expanded(
//                                       child: GestureDetector(
//                                         onTap: () async {
//                                           Navigator.of(context)
//                                               .pushNamed(
//                                             NewsDetailsScreen
//                                                 .routeNamed,
//                                             arguments: {
//                                               'id': newsItem.entryId,
//                                               'image':
//                                               newsItem.imageUrl,
//                                               'content':
//                                               newsItem.content,
//                                               'categoryTitle':
//                                               newsItem
//                                                   .categoryTitle,
//                                               'title':
//                                               newsItem.titleText,
//                                               'link': newsItem.link,
//                                               'publishedAt': newsItem
//                                                   .publishedTime,
//                                               'status':
//                                               newsItem.status,
//                                             },
//                                           );
//                                         },
//                                         child: Column(
//                                           crossAxisAlignment:
//                                           CrossAxisAlignment
//                                               .start,
//                                           children: [
//                                             Text(
//                                               decodedText,
//                                               style: const TextStyle(
//                                                 fontSize: 19,
//                                                 fontWeight:
//                                                 FontWeight.w600,
//                                                 height: 1.1,
//                                               ),
//                                             ),
//                                             Padding(
//                                               padding:
//                                               const EdgeInsets
//                                                   .only(top: 4.0),
//                                               child: Text(
//                                                 '${newsItem.readTime} min read',
//                                                 style: TextStyle(
//                                                   color:
//                                                   colorAppbarForeground,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               onExpanded: Row(
//                                 children: [
//                                   Column(
//                                     children: [
//                                       InkWell(
//                                         onTap: () {
//                                           newsNotifierController
//                                               .toggleFavStatus(
//                                             newsItem.entryId,
//                                             context,
//                                           );
//
//                                           // log(newsItem.id.toString());
//                                         },
//                                         child: Icon(
//                                           size: 27,
//                                           color:
//                                           colorAppbarForeground,
//                                           newsNotifier[index].isFav
//                                               ? Icons.bookmark_added
//                                               : Icons.bookmark_add,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 10),
//                                       const Text('Unstarred'),
//                                     ],
//                                   ),
//                                   const SizedBox(width: 30),
//                                   Column(
//                                     children: [
//                                       InkWell(
//                                         onTap: () {
//                                           Status stat;
//
//                                           if (newsItem.status ==
//                                               Status.read) {
//                                             stat = Status.unread;
//                                           } else {
//                                             stat = Status.read;
//                                           }
//
//                                           newsNotifierController
//                                               .toggleRead(
//                                             newsItem.entryId,
//                                             stat,
//                                             context,
//                                           );
//                                         },
//                                         child: Icon(
//                                           size: 27,
//                                           color: colorRed,
//                                           newsItem.status ==
//                                               Status.unread
//                                               ? Icons.circle
//                                               : Icons.circle_outlined,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 10),
//                                       const Text('Read'),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   /// ///////////////////////////////////////////////////////////////////////////////////////
//
//   PopupMenuButton<DropItems> buildPopupMenuButton(
//       bool isShowRead,
//       Sort sort,
//       void Function() sortFunction,
//       void Function() read,
//       ) {
//     return PopupMenuButton<DropItems>(
//       icon: Icon(
//         Icons.filter_alt,
//         color: isShowRead || sort == Sort.ascending
//             ? colorRed
//             : colorAppbarForeground,
//       ),
//       itemBuilder: (context) => [
//         PopupMenuItem(
//           value: DropItems.sort,
//           child: Row(
//             children: [
//               Icon(
//                 sort == Sort.ascending
//                     ? Icons.arrow_upward
//                     : Icons.arrow_downward,
//                 color: Colors.black,
//               ),
//               const SizedBox(width: 10),
//               Text(
//                 sort == Sort.ascending ? 'Sort Latest' : 'Sort Oldest',
//               ),
//             ],
//           ),
//         ),
//         PopupMenuItem(
//           value: DropItems.read,
//           child: Row(
//             children: [
//               Icon(
//                 Icons.circle_outlined,
//                 color: isShowRead ? colorRed : Colors.black,
//               ),
//               const SizedBox(width: 10),
//               Text(isShowRead ? 'Show All' : 'Show Read'),
//             ],
//           ),
//         ),
//       ],
//       onSelected: (selected) {
//         if (selected == DropItems.sort) {
//           sortFunction();
//         } else if (selected == DropItems.read) {
//           read();
//         }
//       },
//     );
//   }
//
//   Column buildTopColumn(
//       bool isLoadingPage,
//       bool canGoToPreviousPage,
//       void Function() previous,
//       bool canGoToNextPage,
//       void Function() next,
//       ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               isLoadingPage
//                   ? disabledPreviousButton()
//                   : InkWell(
//                 onTap: () {
//                   canGoToPreviousPage ? previous() : null;
//                 },
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.arrow_back,
//                       size: 16,
//                       color: canGoToPreviousPage
//                           ? Colors.redAccent
//                           : Colors.grey,
//                     ),
//                     const SizedBox(width: 5),
//                     Text(
//                       'Previous',
//                       style: TextStyle(
//                         fontSize: 17,
//                         color: canGoToPreviousPage
//                             ? Colors.redAccent
//                             : Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               isLoadingPage
//                   ? disabledMoreButton()
//                   : InkWell(
//                 onTap: () => canGoToNextPage ? next() : null,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'More',
//                       style: TextStyle(
//                         fontSize: 17,
//                         color: canGoToNextPage
//                             ? Colors.redAccent[200]
//                             : Colors.grey,
//                       ),
//                     ),
//                     const SizedBox(width: 5),
//                     Icon(
//                       Icons.arrow_forward,
//                       size: 16,
//                       color: canGoToNextPage
//                           ? Colors.redAccent[200]
//                           : Colors.grey,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Row topSectionRow(News newsItem, String dateTime) {
//     return Row(
//       children: [
//         Text(
//           newsItem.categoryTitle,
//           style: TextStyle(
//             color: colorRed,
//             // fontSize: 15,
//           ),
//         ),
//         Text(
//           ' / ',
//           style: TextStyle(
//             color: Colors.grey[500],
//             // fontSize: 15,
//           ),
//         ),
//         Text(
//           dateTime,
//           style: TextStyle(
//             color: Colors.grey[500],
//             // fontSize: 15,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Row disabledPreviousButton() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: const [
//         Icon(
//           Icons.arrow_back,
//           size: 16,
//           color: Colors.grey,
//         ),
//         SizedBox(width: 5),
//         Text(
//           'Previous',
//           style: TextStyle(
//             fontSize: 17,
//             color: Colors.grey,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Row disabledMoreButton() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: const [
//         Text(
//           'More',
//           style: TextStyle(
//             fontSize: 17,
//             color: Colors.grey,
//           ),
//         ),
//         SizedBox(width: 5),
//         Icon(
//           Icons.arrow_forward,
//           size: 16,
//           color: Colors.grey,
//         ),
//       ],
//     );
//   }
// }
//
// // extension Extract on String {
// //   String? extractImage() {
// //     if (contains('img')) {
// //       return html_parser
// //               .parse(this)
// //               .getElementsByTagName('img')[0]
// //               .attributes['src'] ??
// //           '';
// //     } else {
// //       return '';
// //     }
// //   }
// // }
//
// /*
//
//     '${HtmlParser.parse(
//           "<figure>\n      <img alt=\"\" src=\"https://cdn.vox-cdn.com/thumbor/0eAXXCxHnTICFIF3nz6b8nJwYIA=/8x0:868x573/1310x873/cdn.vox-cdn.com/uploads/chorus_image/image/71292460/tmobile_spacex_satellite.5.png\" loading=\"lazy\"/>\n        <figcaption><em>There are a few companies that want to keep you connected when you’re in remote areas. </em> | Image: SpaceX</figcaption>\n    </figure>\n\n  <p>On Thursday, Elon Musk got on stage with T-Mobile CEO Mike Sievert to announce that SpaceX is working with the carrier to <a href=\"https://www.theverge.com/2022/8/25/23320722/spacex-starlink-t-mobile-satellite-internet-mobile-messaging\" rel=\"noopener noreferrer\" target=\"_blank\" referrerpolicy=\"no-referrer\">completely eliminate cellular dead zones</a>. The companies claim that next-generation Starlink satellites, set to launch next year, will be able to communicate directly with phones, letting you text, make calls, and potentially stream video even when there are no cell towers nearby. What’s more, Musk promised all this is possible with phones that people are using today, without consumers having to buy any extra equipment.</p>\n<p>It’s a bold proclamation from the carrier — Verizon and AT&amp;T don’t offer anything like it. However, SpaceX and T-Mobile aren’t the only companies looking to use satellites to directly communicate with...</p>\n  <p>\n    <a href=\"https://www.theverge.com/2022/8/27/23324128/t-mobile-spacex-satellite-to-phone-technology-ast-lynk-industry-reactions-apple\" rel=\"noopener noreferrer\" target=\"_blank\" referrerpolicy=\"no-referrer\">Continue reading…</a>\n  </p>",
//         ).getElementsByTagName('img')[0].attributes['src']}',
//
//  */
//
// /// For Grouped List View
// /*
//     List nowList = newsNotifier.where((element) {
//       log(DateFormat('dd MMM yyyy').format(
//         element.publishedTime,
//       ).toString());
//
//       log(DateFormat('dd MMM yyyy').format(
//         DateTime.now(),
//       ).toString());
//
//       return DateFormat('dd MMM yyyy').format(
//         element.publishedTime,
//       ) == DateFormat('dd MMM yyyy').format(
//         DateTime.now(),
//       );
//     }).toList();
//
//     log('LENGth: ${nowList.length}');
//  */
