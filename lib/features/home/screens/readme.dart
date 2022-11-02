
// final searchProvider = Provider((ref) {
//   final newsItem = News(
//     entryId: 0,
//     feedId: 0,
//     categoryTitle: '',
//     text: '',
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
//       newsItem.content.substring(startIndex, endIndex + "https".length - 2);
// });

/// IconButton Actions-
//           // IconButton(
//           //   onPressed: () {
//           //     isLoadingPageController.update((state) => true);
//           //
//           //     isShowReadController.update((state) => state = !state);
//           //     ref.refresh(newsNotifierProvider.notifier).fetchEntries().then(
//           //           (value) =>
//           //               isLoadingPageController.update((state) => false),
//           //         );
//           //   },
//           //   icon: Icon(
//           //     isShowRead ? Icons.circle : Icons.circle_outlined,
//           //     color: Colors.redAccent[200],
//           //   ),
//           // ),

// IconButton(
//   onPressed: sort,
//   icon: Icon(
//     Icons.sort,
//     color: Colors.redAccent[200],
//   ),
// ),
// IconButton(
//   onPressed: () {
//     isLoadingPageController.update((state) => true);
//
//     ref.refresh(offsetProvider);
//     ref.refresh(sortDirectionProvider);
//     ref.refresh(starredProvider);
//     ref.refresh(isShowReadProvider);
//
//     ref.refresh(newsNotifierProvider.notifier).fetchEntries().then(
//           (value) =>
//               isLoadingPageController.update((state) => false),
//         );
//   },
//   icon: Icon(
//     Icons.refresh,
//     color: Colors.redAccent[200],
//   ),
// ),

// IconButton(
//   onPressed: () {
//     starredController.update((state) => !state);
//     isLoadingPageController.update((state) => true);
//
//     ref.refresh(newsNotifierProvider.notifier).fetchEntries().then(
//           (value) =>
//               isLoadingPageController.update((state) => false),
//         );
//   },
//   icon: Icon(
//     starred ? Icons.filter_alt : Icons.star_border_outlined,
//     color: Colors.redAccent[200],
//   ),
// ),

/// Top Bar
/*
              Container(
                color: Colors.grey[100],
                height: MediaQuery.of(context).size.height * 0.07,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 7,
                        horizontal: 7,
                      ),
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          backgroundColor: Colors.white,
                          fixedSize: const Size(120, 50),
                        ),
                        child: const Text('Hey'),
                      ),
                    );
                  },
                ),
              ),
 */

/// Old ListTile View
/*
                          ListTile(
                            minLeadingWidth: 40 - 10,
                            // title //
                            title:
                            GestureDetector(
                              onTap: () async {
                                Navigator.of(context).pushNamed(
                                  NewsDetailsScreen.routeNamed,
                                  arguments: {
                                    'id': newsItem.entryId,
                                    'image': newsItem.imageUrl,
                                    'content': newsItem.content,
                                    'categoryTitle':
                                        newsItem.categoryTitle,
                                    'title': newsItem.text,
                                    'link': newsItem.link,
                                    'publishedAt': newsItem.publishedTime,
                                  },
                                );
                              },
                              child: Text(
                                newsItem.text,
                                style: const TextStyle(fontSize: 17),
                              ),
                            ),

                            // leading //
                            leading: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    newsNotifierController
                                        .toggleFavStatus(
                                            newsItem.entryId);

                                    // log(newsItem.id.toString());
                                  },
                                  child: Icon(
                                    newsNotifier[index].isFav
                                        ? Icons.bookmark_added
                                        : Icons.bookmark_add,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () {
                                    String stat;
                                    if (newsItem.status == 'read') {
                                      stat = 'unread';
                                    } else {
                                      stat = 'read';
                                    }

                                    newsNotifierController.toggleRead(
                                        newsItem.entryId, stat);
                                  },
                                  child: Icon(
                                    newsItem.status == 'unread'
                                        ? Icons.circle
                                        : Icons.circle_outlined,
                                  ),
                                ),
                              ],
                            ),
                            // Bottom Section
                            subtitle: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Image.network(
                                //   newsItem.imageUrl,
                                //   height: 90,
                                //   width: 130,
                                //   fit: BoxFit.cover,
                                // ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.end,
                                  children: [
                                    const SizedBox(height: 7),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                          maxWidth: 190),
                                      child: Text(
                                        // textAlign: TextAlign.end,
                                        newsItem.categoryTitle,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            // color: Colors.black,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    const SizedBox(height: 7),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 0),
                                      child: Text(
                                        dateUsed,
                                      ),
                                    ),
                                    // const SizedBox(height: 2),
                                    // GestureDetector(
                                    //   onTap: () async {
                                    //     log('${await ref.watch(newsNotifierProvider.notifier).viewEntryDetails(newsItem.feedId, newsItem.entryId)}');
                                    //   },
                                    //   child: Text(
                                    //       '${newsItem.readTime} mins read'),
                                    // ),
                                    // GestureDetector(
                                    //   onTap: () async {
                                    //     Navigator.of(context).pushNamed(
                                    //       NewsDetailsScreen.routeNamed,
                                    //       arguments: {
                                    //         'id': newsItem.entryId,
                                    //         'image': newsItem.imageUrl,
                                    //         'content': newsItem.content,
                                    //         'selectedFeed': await ref
                                    //             .watch(
                                    //                 newsNotifierProvider.notifier)
                                    //             .viewEntryDetails(newsItem.feedId,
                                    //                 newsItem.entryId)
                                    //         // {'f': 'g'}
                                    //         ,
                                    //         'link': newsItem.link,
                                    //         'publishedAt': dateFormatted,
                                    //       },
                                    //     );
                                    //   },
                                    //   child: const Text('read more'),
                                    // ),
                                  ],
                                ),
                              ],
                            ),
                          ),
 */

/// Expansion Experiment
/*
                          ExpansionTile(
                            // trailing: const SizedBox(),
                            textColor: Colors.black,
                            collapsedTextColor: Colors.black,

                            title: Text('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),
                          ),
                          Container(
                            margin: const EdgeInsets.all(8.0),
                            child: ExpansionPanelList(
                              elevation: 0,
                              expansionCallback: (context, isExpanded) {
                                setState(() {
                                  newsItem.isExpanded = !isExpanded;
                                });
                              },
                              children: [
                                ExpansionPanel(
                                  backgroundColor: colorAppbarBackground,
                                  isExpanded: newsItem.isExpanded,
                                  canTapOnHeader: true,
                                  headerBuilder: (context, isExpanded) {
                                    return Text(
                                      '${newsItem.text}',
                                      style: TextStyle(fontSize: 16),
                                    );
                                  },
                                  body: Text('hhhhh'),
                                ),
                              ],
                            ),
                          ),
 */
