// import 'dart:developer' show log;
//
// import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:news_app/features/search/screens/search_screen.dart';
// import 'package:universal_platform/universal_platform.dart';
//
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:news_app/features/details/screens/news_details_screen.dart';
// import 'package:news_app/widgets/app_drawer.dart';
// import 'package:fade_shimmer/fade_shimmer.dart';
//
// import '../../models/news.dart';
// import '../home/repository/home_feed_repo.dart';
//
// // final sortProvider = StateProvider<bool>((ref) => false);
// //
// // final sortingProvider = StateProvider<String>((ref) {
// //   bool sortType = ref.watch(sortProvider);
// //   if (sortType) {
// //     log('asc');
// //     return 'asc';
// //   } else {
// //     log('desc');
// //     return 'desc';
// //   }
// // });
//
// final sortDirectionProvider = StateProvider<String>((ref) => 'asc');
//
// final isShowReadProvider = StateProvider<bool>((ref) => false);
//
// final isLoadingNewsProvider = StateProvider<bool>((ref) => false);
//
// final isLoadingPageProvider = StateProvider<bool>((ref) => false);
//
// final starredProvider = StateProvider<bool>((ref) => false);
//
// final isSelectedProvider =
// StateProvider<List<bool>>((ref) => [true, false, false]);
//
// final nextProvider = FutureProvider((ref) {
//   final num = ref.watch(homeFeedProvider.notifier).pageNumber();
//   return num;
// });
//
// final isNextProvider = StateProvider(
//       (ref) {
//     final max = ref.watch(nextProvider).value;
//     final newsNotifier = ref.watch(homeFeedProvider);
//     final offset = ref.watch(offsetProvider);
//
//     final curr = ((newsNotifier.length + offset) / 100).ceil().toInt();
//     // log('MAX: $max, CURR: $curr');
//
//     if (max == curr) {
//       return false;
//     } else {
//       return true;
//     }
//   },
// );
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
//     final isLoadingNewsController = ref.read(isLoadingNewsProvider.notifier);
//
//     Future.delayed(Duration.zero).then(
//           (value) => isLoadingNewsController.update((state) => true),
//     );
//
//     ref
//         .read(homeFeedProvider.notifier)
//         .fetchEntries()
//     //     .catchError((error) {
//     //   return showDialog(
//     //     context: context,
//     //     builder: (ctx) => AlertDialog(
//     //       title: const Text('An Error Occurred!'),
//     //       content: Text('$error'),
//     //       actions: [
//     //         TextButton(
//     //           onPressed: () {
//     //             Navigator.of(ctx).pop();
//     //           },
//     //           child: const Text('Okay'),
//     //         )
//     //       ],
//     //     ),
//     //   );
//     // })
//         .then(
//           (_) => isLoadingNewsController.update((state) => false),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // log('************ HOME FEED SCREEN *****************');
//
//     final isLoadingNews = ref.watch(isLoadingNewsProvider);
//     // final isLoadingNewsController = ref.read(isLoadingNewsProvider.notifier);
//
//     // useEffect(
//     //   () {
//     //
//     //     return null;
//     //   },
//     //   [],
//     // );
//
//     // log('${ref.read(categoryListNotifierFuture(context)).whenData((value) => value).value}');
//
//     // final catNames = ref.watch(categoryNamesProvider(context)).value;
//     // List<Tab>? categoryNames = catNames?.map((e) => e).toList() ?? [Tab(text: 'Wait')];
//
//     // log(categoryNames.toString());
//
//     final isLoadingPage = ref.watch(isLoadingPageProvider);
//     final isLoadingPageController = ref.read(isLoadingPageProvider.state);
//
//     final starred = ref.watch(starredProvider);
//     final starredController = ref.read(starredProvider.notifier);
//
//     var newsNotifier = ref.watch(homeFeedProvider);
//     final newsNotifierController = ref.read(homeFeedProvider.notifier);
//
//     // final itemCount = ref.watch(getCountProvider);
//     final sortDirectionController = ref.read(sortDirectionProvider.state);
//
//     final isShowRead = ref.watch(isShowReadProvider);
//     final isShowReadController = ref.read(isShowReadProvider.state);
//
//     final isSelected = ref.watch(isSelectedProvider);
//     final isSelectedController = ref.read(isSelectedProvider.notifier);
//
//     final canGoToNextPage = ref.watch(isNextProvider);
//     final canGoToPreviousPage = ref.watch(offsetProvider) != 0;
//
//     void sort() {
//       // sortLatestFirstController.update((state) => state = !state);
//       isLoadingPageController.update((state) => true);
//       ref.refresh(offsetProvider);
//
//       sortDirectionController.update((state) {
//         if (state == 'asc') {
//           return state = 'desc';
//         } else {
//           return state = 'asc';
//         }
//       });
//
//       ref.refresh(homeFeedProvider.notifier).fetchEntries().then(
//             (value) => isLoadingPageController.update((state) => false),
//       );
//     }
//
//     void previous() {
//       isLoadingPageController.update((state) => true);
//
//       ref.read(offsetProvider.notifier).update((state) => state -= 100);
//       // log('PREVIOUS-OFFSET: ${ref.watch(offsetProvider)}');
//
//       ref.read(homeFeedProvider.notifier).fetchEntries().then(
//             (_) => isLoadingPageController.update((state) => false),
//       );
//     }
//
//     void next() {
//       isLoadingPageController.update((state) => true);
//
//       ref.read(offsetProvider.notifier).update((state) => state += 100);
//
//       ref.read(homeFeedProvider.notifier).fetchEntries().then(
//             (_) {
//           // log(newsNotifier.length.toString());
//           isLoadingPageController.update((state) => false);
//         },
//       );
//     }
//
//     // log('${ref.watch(isListEmptyProvider)}');
//     // log(ref.watch(nextProvider).value.toString());
//     // log('NEXT: ${ref.watch(isNextProvider)}');
//     // log('OFFSET: ${ref.watch(offsetProvider)}');
//
//     /////////////////////////////////////////////////////////////////////////////////////////
//
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             // '${itemCount.when(
//             //   data: (data) => data,
//             //   error: (e, s) => 'E',
//             //   loading: () => 'L',
//             // )} - ${newsNotifier.length + ref.watch(offsetProvider)}',
//               'All Feeds'),
//           actions: [
//             IconButton(
//               onPressed: () {
//                 isLoadingPageController.update((state) => true);
//
//                 isShowReadController.update((state) => state = !state);
//                 ref.refresh(homeFeedProvider.notifier).fetchEntries().then(
//                       (value) =>
//                       isLoadingPageController.update((state) => false),
//                 );
//               },
//               icon: Icon(
//                 isShowRead ? Icons.circle : Icons.circle_outlined,
//                 color: Colors.redAccent[200],
//               ),
//             ),
//             IconButton(
//               onPressed: sort,
//               icon: Icon(
//                 Icons.sort,
//                 color: Colors.redAccent[200],
//               ),
//             ),
//             IconButton(
//               onPressed: () {
//                 isLoadingPageController.update((state) => true);
//
//                 ref.refresh(offsetProvider);
//                 ref.refresh(sortDirectionProvider);
//                 ref.refresh(starredProvider);
//                 ref.refresh(isShowReadProvider);
//
//                 ref.refresh(homeFeedProvider.notifier).fetchEntries().then(
//                       (value) =>
//                       isLoadingPageController.update((state) => false),
//                 );
//               },
//               icon: Icon(
//                 Icons.refresh,
//                 color: Colors.redAccent[200],
//               ),
//             ),
//             IconButton(
//               onPressed: () {
//                 starredController.update((state) => !state);
//                 isLoadingPageController.update((state) => true);
//
//                 ref.refresh(homeFeedProvider.notifier).fetchEntries().then(
//                       (value) =>
//                       isLoadingPageController.update((state) => false),
//                 );
//               },
//               icon: Icon(
//                 starred ? Icons.star : Icons.star_border_outlined,
//                 color: Colors.redAccent[200],
//               ),
//             ),
//           ],
//           bottom: const TabBar(
//             tabs: [
//               Tab(
//                 child: Text(
//                   'Feeds',
//                   style: TextStyle(color: Colors.black),
//                 ),
//               ),
//               Tab(
//                 child: Text(
//                   'Discover',
//                   style: TextStyle(color: Colors.black),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         drawer: const AppDrawer(),
//
//         ///////////////////////////////////////////////////////////////////////////////////////////
//         // BODY //
//
//         body: TabBarView(
//           children: [
//             Column(
//               children: [
//                 // Top Column
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Container(
//                     //   color: Colors.grey[100],
//                     //   height: MediaQuery.of(context).size.height * 0.07,
//                     //
//                     //   child: ,
//                     //
//                     //   // child: ListView.builder(
//                     //   //   scrollDirection: Axis.horizontal,
//                     //   //   itemCount: 5,
//                     //   //   itemBuilder: (context, i) {
//                     //   //     return Padding(
//                     //   //       padding: const EdgeInsets.symmetric(
//                     //   //         vertical: 7,
//                     //   //         horizontal: 7,
//                     //   //       ),
//                     //   //       child: TextButton(
//                     //   //         onPressed: () {},
//                     //   //         style: TextButton.styleFrom(
//                     //   //           foregroundColor: Colors.redAccent,
//                     //   //           backgroundColor: Colors.white,
//                     //   //           fixedSize: const Size(120, 50),
//                     //   //         ),
//                     //   //         child: const Text('Hey'),
//                     //   //       ),
//                     //   //     );
//                     //   //   },
//                     //   // ),
//                     // ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           InkWell(
//                             onTap: () {
//                               canGoToPreviousPage ? previous() : null;
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.arrow_back,
//                                   size: 16,
//                                   color: canGoToPreviousPage
//                                       ? Colors.redAccent
//                                       : Colors.grey,
//                                 ),
//                                 const SizedBox(width: 5),
//                                 Text(
//                                   'Previous',
//                                   style: TextStyle(
//                                     fontSize: 17,
//                                     color: canGoToPreviousPage
//                                         ? Colors.redAccent
//                                         : Colors.grey,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           InkWell(
//                             onTap: () {
//                               canGoToNextPage ? next() : null;
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   'More',
//                                   style: TextStyle(
//                                     fontSize: 17,
//                                     color: canGoToNextPage
//                                         ? Colors.redAccent[200]
//                                         : Colors.grey,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 5),
//                                 Icon(
//                                   Icons.arrow_forward,
//                                   size: 16,
//                                   color: canGoToNextPage
//                                       ? Colors.redAccent[200]
//                                       : Colors.grey,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 /////////////////////////////////////////////////////////////////////////////////////
//                 // DISPLAY BODY //
//
//                 if (isLoadingNews || isLoadingPage)
//                   const Expanded(child: Center(child: Text('Loading...')))
//                 else
//                   Expanded(
//                     child: ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: newsNotifier.length,
//                       itemBuilder: (context, index) {
//                         final newsItem = newsNotifier[index];
//
//                         final dateFormatted = DateFormat('dd/MM/yyyy').format(
//                           newsItem.publishedTime,
//                         );
//
//                         return Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             ListTile(
//                               minLeadingWidth: 40 - 10,
//                               // title //
//                               title: GestureDetector(
//                                 onTap: () async {
//                                   Navigator.of(context).pushNamed(
//                                     NewsDetailsScreen.routeNamed,
//                                     arguments: {
//                                       'id': newsItem.entryId,
//                                       'image': newsItem.imageUrl,
//                                       'content': newsItem.content,
//                                       'categoryTitle': newsItem.categoryTitle,
//                                       'title': newsItem.titleText,
//                                       'link': newsItem.link,
//                                       'publishedAt': newsItem.publishedTime,
//                                     },
//                                   );
//                                 },
//                                 child: Text(
//                                   newsItem.titleText,
//                                   style: const TextStyle(fontSize: 17),
//                                 ),
//                               ),
//
//                               // leading //
//                               leading: Column(
//                                 children: [
//                                   InkWell(
//                                     onTap: () {
//                                       newsNotifierController
//                                           .toggleFavStatus(newsItem.entryId);
//
//                                       // log(newsItem.id.toString());
//                                     },
//                                     child: Icon(
//                                       newsNotifier[index].isFav
//                                           ? Icons.bookmark_added
//                                           : Icons.bookmark_add,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   InkWell(
//                                     onTap: () {
//                                       String stat;
//                                       if (newsItem.status == 'read') {
//                                         stat = 'unread';
//                                       } else {
//                                         stat = 'read';
//                                       }
//
//                                       newsNotifierController.toggleRead(
//                                           newsItem.entryId, stat);
//                                     },
//                                     child: Icon(
//                                       newsItem.status == 'unread'
//                                           ? Icons.circle
//                                           : Icons.circle_outlined,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               // Bottom Section
//                               subtitle: Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   // Image.network(
//                                   //   newsItem.imageUrl,
//                                   //   height: 90,
//                                   //   width: 130,
//                                   //   fit: BoxFit.cover,
//                                   // ),
//                                   Column(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     children: [
//                                       const SizedBox(height: 7),
//                                       ConstrainedBox(
//                                         constraints:
//                                         const BoxConstraints(maxWidth: 190),
//                                         child: Text(
//                                           // textAlign: TextAlign.end,
//                                           newsItem.categoryTitle,
//                                           overflow: TextOverflow.ellipsis,
//                                           maxLines: 1,
//                                           style: const TextStyle(
//                                               fontSize: 15,
//                                               // color: Colors.black,
//                                               fontWeight: FontWeight.w400),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                     children: [
//                                       const SizedBox(height: 7),
//                                       Padding(
//                                         padding: const EdgeInsets.only(left: 0),
//                                         child: Text(
//                                           dateFormatted,
//                                         ),
//                                       ),
//                                       // const SizedBox(height: 2),
//                                       // GestureDetector(
//                                       //   onTap: () async {
//                                       //     log('${await ref.watch(newsNotifierProvider.notifier).viewEntryDetails(newsItem.feedId, newsItem.entryId)}');
//                                       //   },
//                                       //   child: Text(
//                                       //       '${newsItem.readTime} mins read'),
//                                       // ),
//                                       // GestureDetector(
//                                       //   onTap: () async {
//                                       //     Navigator.of(context).pushNamed(
//                                       //       NewsDetailsScreen.routeNamed,
//                                       //       arguments: {
//                                       //         'id': newsItem.entryId,
//                                       //         'image': newsItem.imageUrl,
//                                       //         'content': newsItem.content,
//                                       //         'selectedFeed': await ref
//                                       //             .watch(
//                                       //                 newsNotifierProvider.notifier)
//                                       //             .viewEntryDetails(newsItem.feedId,
//                                       //                 newsItem.entryId)
//                                       //         // {'f': 'g'}
//                                       //         ,
//                                       //         'link': newsItem.link,
//                                       //         'publishedAt': dateFormatted,
//                                       //       },
//                                       //     );
//                                       //   },
//                                       //   child: const Text('read more'),
//                                       // ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 15),
//                             // const Divider(thickness: 1),
//                           ],
//                         );
//                       },
//                     ),
//                   ),
//               ],
//             ),
//             SearchScreen(),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// final searchProvider = Provider((ref) {
//   final newsItem = News(
//     entryId: 0,
//     feedId: 0,
//     categoryTitle: '',
//     titleText: '',
//     author: '',
//     readTime: 0,
//     isFav: false,
//     link: '',
//     content: '',
//     imageUrl: '',
//     status: '',
//     publishedTime: DateTime.now(),
//   );
//
//   int startIndex = newsItem.content.indexOf('https');
//   int endIndex = newsItem.content.indexOf('jpg');
//
//   if (endIndex == -1) {
//     print('CAUGHT');
//     endIndex = newsItem.content.indexOf('png');
//   }
//
//   final link =
//   newsItem.content.substring(startIndex, endIndex + "https".length - 2);
// });
