// import 'dart:developer' show log;
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:news_app/features/details/screens/news_details_screen.dart';
// import 'package:news_app/features/home/widgets/app_drawer.dart';
// import 'package:news_app/models/category_providers.dart';
// import 'package:news_app/models/user_providers.dart';
//
// import '../../../models/home_feed_repo.dart';
//
// final sortProvider = StateProvider<bool>((ref) => false);
//
// // final isReadProvider = StateProvider<bool>((ref) => false);
//
// final isShowReadProvider = StateProvider<bool>((ref) => false);
//
// class CategoryFeedScreen extends ConsumerWidget {
//   static const routeNamed = '/home';
//
//   const CategoryFeedScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     log('************ CATEGORY FEED SCREEN *****************');
//     final fetcher = ref.watch(fetchNewsFuture);
//     var feeds = ref.watch(newsNotifierProvider);
//
//     ref.read(userNotifierProvider.notifier).fetchUserData();
//     ref.read(categoryNotifierProvider.notifier).fetchCategoryData();
//     // log('${ref.watch(categoryNotifierProvider)}');
//
//     final newsToggle = ref.read(newsNotifierProvider.notifier);
//
//     final itemCount = ref.watch(getCountProvider).value ?? 0;
//     final sortLatestFirstController = ref.read(sortProvider.state);
//
//     final isShowRead = ref.watch(isShowReadProvider);
//
//     final isShowReadController = ref.read(isShowReadProvider.state);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('($itemCount) Items'),
//         actions: [
//           IconButton(
//             onPressed: () {
//               isShowReadController.update((state) => state = !state);
//             },
//             icon: Icon(
//               isShowRead ? Icons.circle : Icons.circle_outlined,
//             ),
//           ),
//           IconButton(
//             onPressed: () {
//               sortLatestFirstController.update((state) => state = !state);
//               ref.refresh(newsNotifierProvider.notifier).fetchFeeds();
//             },
//             icon: const Icon(Icons.sort),
//           ),
//           IconButton(
//             onPressed: () {
//               ref.refresh(newsNotifierProvider.notifier).fetchFeeds();
//             },
//             icon: const Icon(Icons.refresh),
//           ),
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.more_vert),
//           ),
//         ],
//       ),
//       drawer: const AppDrawer(),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(
//                 child: fetcher.when(
//                   data: (feed) {
//                     return ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: feeds.length,
//                       itemBuilder: (context, index) {
//                         final newsItem = feeds[index];
//
//                         // final feedTitle = feed['entries'][index]['title'];
//                         // log('Length - ${feeds.length}');
//                         // log('ID - ${feeds[index].id}');
//
//                         return Column(
//                           children: [
//                             ListTile(
//                               minLeadingWidth: 40 - 10,
//                               title: Text(
//                                 newsItem.text,
//                                 style: const TextStyle(fontSize: 17),
//                               ),
//                               leading: Column(
//                                 children: [
//                                   InkWell(
//                                     onTap: () {
//                                       newsToggle.toggleFavStatus(newsItem.id);
//
//                                       log(newsItem.id.toString());
//                                     },
//                                     child: Icon(
//                                       newsItem.isFav
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
//                                       newsToggle.toggleRead(newsItem.id, stat);
//                                     },
//                                     child: Icon(
//                                       newsItem.status == 'unread'
//                                           ? Icons.circle
//                                           : Icons.circle_outlined,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               subtitle: Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Image.network(
//                                     newsItem.imageUrl,
//                                     height: 90,
//                                     width: 130,
//                                     fit: BoxFit.cover,
//                                   ),
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                     children: [
//                                       const SizedBox(height: 5),
//                                       ConstrainedBox(
//                                         constraints: const BoxConstraints(maxWidth: 190),
//                                         child: Text(
//                                           textAlign: TextAlign.end,
//                                           '-- ${newsItem.author}',
//                                           overflow: TextOverflow.ellipsis,
//                                           maxLines: 2,
//                                         ),
//                                       ),
//                                       Text('${newsItem.readTime} mins read'),
//                                       GestureDetector(
//                                         onTap: () async {
//                                           Navigator.of(context).pushNamed(
//                                             NewsDetailsScreen.routeNamed,
//                                             arguments: {
//                                               'id': newsItem.id,
//                                               'image': newsItem.imageUrl,
//                                               'content': newsItem.content,
//                                               'selectedFeed': await ref
//                                                   .watch(newsNotifierProvider
//                                                   .notifier)
//                                                   .viewFeed(newsItem.id),
//                                               'link': newsItem.link,
//                                             },
//                                           );
//                                         },
//                                         child: const Text('read more'),
//                                       ),
//                                     ],
//                                   )
//                                 ],
//                               ),
//                             ),
//                             const Divider(thickness: 1),
//                           ],
//                         );
//                       },
//                     );
//                   },
//                   error: (e, s) => Text('$e'),
//                   loading: () => const Center(
//                     child: Text('Loading...'),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
