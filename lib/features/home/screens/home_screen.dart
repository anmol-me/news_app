// import 'dart:developer' show log;
//
// import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
//
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:news_app/features/details/screens/news_details_screen.dart';
// import 'package:news_app/features/home/widgets/app_drawer.dart';
// import '../../category/repository/home_feed_repo.dart';
// import '../../category/repository/subscription_repository.dart';
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
// final nextProvider = FutureProvider((ref) {
//   final num = ref.watch(newsNotifierProvider.notifier).pageNumber();
//   return num;
// });
//
// final isNextProvider = StateProvider(
//       (ref) {
//     final max = ref.watch(nextProvider).value;
//     final newsNotifier = ref.watch(newsNotifierProvider);
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
// class HomeScreen extends HookConsumerWidget {
//   static const routeNamed = '/home-screen';
//
//   const HomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // log('************ HOME FEED SCREEN *****************');
//
//     final isLoadingNews = ref.watch(isLoadingNewsProvider);
//     final isLoadingNewsController = ref.read(isLoadingNewsProvider.notifier);
//
//     useEffect(
//           () {
//         Future.delayed(Duration.zero).then(
//               (value) => isLoadingNewsController.update((state) => true),
//         );
//
//         ref
//             .read(newsNotifierProvider.notifier)
//             .fetchEntries()
//         //     .catchError((error) {
//         //   return showDialog(
//         //     context: context,
//         //     builder: (ctx) => AlertDialog(
//         //       title: const Text('An Error Occurred!'),
//         //       content: Text('$error'),
//         //       actions: [
//         //         TextButton(
//         //           onPressed: () {
//         //             Navigator.of(ctx).pop();
//         //           },
//         //           child: const Text('Okay'),
//         //         )
//         //       ],
//         //     ),
//         //   );
//         // })
//             .then(
//               (_) => isLoadingNewsController.update((state) => false),
//         );
//         return null;
//       },
//       [],
//     );
//
//     final isLoadingPage = ref.watch(isLoadingPageProvider);
//     final isLoadingPageController = ref.read(isLoadingPageProvider.state);
//
//     final starred = ref.watch(starredProvider);
//     final starredController = ref.read(starredProvider.notifier);
//
//     var newsNotifier = ref.watch(newsNotifierProvider);
//     final newsNotifierController = ref.read(newsNotifierProvider.notifier);
//
//     final itemCount = ref.watch(getCountProvider);
//     final sortDirectionController = ref.read(sortDirectionProvider.state);
//
//     final isShowRead = ref.watch(isShowReadProvider);
//     final isShowReadController = ref.read(isShowReadProvider.state);
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
//       ref.refresh(newsNotifierProvider.notifier).fetchEntries().then(
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
//       ref.read(newsNotifierProvider.notifier).fetchEntries().then(
//             (_) => isLoadingPageController.update((state) => false),
//       );
//     }
//
//     void next() {
//       isLoadingPageController.update((state) => true);
//
//       ref.read(offsetProvider.notifier).update((state) => state += 100);
//
//       ref.read(newsNotifierProvider.notifier).fetchEntries().then(
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
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           '${itemCount.when(
//             data: (data) => data,
//             error: (e, s) => 'E',
//             loading: () => 'L',
//           )} - ${newsNotifier.length + ref.watch(offsetProvider)}',
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {
//               isLoadingPageController.update((state) => true);
//
//               isShowReadController.update((state) => state = !state);
//               ref.refresh(newsNotifierProvider.notifier).fetchEntries().then(
//                     (value) => isLoadingPageController.update((state) => false),
//               );
//             },
//             icon: Icon(
//               isShowRead ? Icons.circle : Icons.circle_outlined,
//               color: Colors.redAccent[200],
//             ),
//           ),
//           IconButton(
//             onPressed: sort,
//             icon: Icon(
//               Icons.sort,
//               color: Colors.redAccent[200],
//             ),
//           ),
//           IconButton(
//             onPressed: () {
//               isLoadingPageController.update((state) => true);
//
//               ref.refresh(offsetProvider);
//               ref.refresh(sortDirectionProvider);
//               ref.refresh(starredProvider);
//               ref.refresh(isShowReadProvider);
//
//               ref.refresh(newsNotifierProvider.notifier).fetchEntries().then(
//                     (value) => isLoadingPageController.update((state) => false),
//               );
//             },
//             icon: Icon(
//               Icons.refresh,
//               color: Colors.redAccent[200],
//             ),
//           ),
//           IconButton(
//             onPressed: () {
//               starredController.update((state) => !state);
//               isLoadingPageController.update((state) => true);
//
//               ref.refresh(newsNotifierProvider.notifier).fetchEntries().then(
//                     (value) => isLoadingPageController.update((state) => false),
//               );
//             },
//             icon: Icon(
//               starred ? Icons.star : Icons.star_border_outlined,
//               color: Colors.redAccent[200],
//             ),
//           ),
//         ],
//       ),
//       drawer: const AppDrawer(),
//       body: Column(
//         children: [
//           // Top Column
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     InkWell(
//                       onTap: () {
//                         canGoToPreviousPage ? previous() : null;
//                       },
//                       child: Text(
//                         'Previous',
//                         style: TextStyle(
//                           color:
//                           canGoToPreviousPage ? Colors.black : Colors.grey,
//                         ),
//                       ),
//                     ),
//                     InkWell(
//                       onTap: () {
//                         canGoToNextPage ? next() : null;
//                       },
//                       child: Text(
//                         'Next',
//                         style: TextStyle(
//                           color: canGoToNextPage ? Colors.black : Colors.grey,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           // DISPLAY BODY //
//           if (isLoadingNews || isLoadingPage)
//             const Expanded(child: Center(child: Text('Loading...')))
//           else
//             Expanded(
//               child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: newsNotifier.length,
//                   itemBuilder: (context, index) {
//                     final newsItem = newsNotifier[index];
//
//                     final dateFormatted = DateFormat('dd/MM/yyyy hh:mm')
//                         .format(newsItem.publishedTime);
//
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.only(left: 40),
//                           child: Text(
//                             dateFormatted,
//                           ),
//                         ),
//                         ListTile(
//                           minLeadingWidth: 40 - 10,
//                           title: Text(
//                             newsItem.text,
//                             style: const TextStyle(fontSize: 17),
//                           ),
//                           leading: Column(
//                             children: [
//                               InkWell(
//                                 onTap: () {
//                                   newsNotifierController
//                                       .toggleFavStatus(newsItem.entryId);
//
//                                   // log(newsItem.id.toString());
//                                 },
//                                 child: Icon(
//                                   newsNotifier[index].isFav
//                                       ? Icons.bookmark_added
//                                       : Icons.bookmark_add,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               InkWell(
//                                 onTap: () {
//                                   String stat;
//                                   if (newsItem.status == 'read') {
//                                     stat = 'unread';
//                                   } else {
//                                     stat = 'read';
//                                   }
//
//                                   newsNotifierController.toggleRead(
//                                       newsItem.entryId, stat);
//                                 },
//                                 child: Icon(
//                                   newsItem.status == 'unread'
//                                       ? Icons.circle
//                                       : Icons.circle_outlined,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           // Bottom Section
//                           subtitle: Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               // Image.network(
//                               //   newsItem.imageUrl,
//                               //   height: 90,
//                               //   width: 130,
//                               //   fit: BoxFit.cover,
//                               // ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   const SizedBox(height: 5),
//                                   ConstrainedBox(
//                                     constraints:
//                                     const BoxConstraints(maxWidth: 190),
//                                     child: Text(
//                                       textAlign: TextAlign.end,
//                                       '-- ${newsItem.author}',
//                                       overflow: TextOverflow.ellipsis,
//                                       maxLines: 2,
//                                     ),
//                                   ),
//                                   Text('${newsItem.readTime} mins read'),
//                                   GestureDetector(
//                                     onTap: () async {
//                                       Navigator.of(context).pushNamed(
//                                         NewsDetailsScreen.routeNamed,
//                                         arguments: {
//                                           'id': newsItem.entryId,
//                                           'image': newsItem.imageUrl,
//                                           'content': newsItem.content,
//                                           'selectedFeed': await ref
//                                               .watch(
//                                               newsNotifierProvider.notifier)
//                                               .viewEntryDetails(newsItem.feedId,
//                                               newsItem.entryId)
//                                           // {'f': 'g'}
//                                           ,
//                                           'link': newsItem.link,
//                                           'publishedAt': dateFormatted,
//                                         },
//                                       );
//                                     },
//                                     child: const Text('read more'),
//                                   ),
//                                 ],
//                               )
//                             ],
//                           ),
//                         ),
//                         const Divider(thickness: 1),
//                       ],
//                     );
//                   }),
//             ),
//         ],
//       ),
//     );
//   }
// }
