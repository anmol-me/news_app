import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/common/common_widgets.dart';
import 'package:news_app/features/home/screens/home_feed_screen.dart';
import 'package:news_app/features/search/repository/search_repo.dart';

import '../../../common/common_methods.dart';
import '../../home/repository/home_feed_repo.dart';

/// Providers
final showResultsProvider = StateProvider.autoDispose((ref) => false);

final showSearchLoaderProvider = StateProvider((ref) => false);

/// Widgets
class SearchScreen extends HookConsumerWidget {
  static const routeNamed = '/search-screen';

  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchTextController = useTextEditingController();

    final showResults = ref.watch(showResultsProvider);
    final showResultsController = ref.watch(showResultsProvider.notifier);

    final showSearchLoader = ref.watch(showSearchLoaderProvider);
    final showSearchLoaderController =
        ref.watch(showSearchLoaderProvider.notifier);

    final searchNotifier = ref.watch(searchNotifierProvider);
    final searchNotifierController = ref.watch(searchNotifierProvider.notifier);

    final newsNotifierController = ref.watch(homeFeedProvider.notifier);

    void searchFunction() {
      FocusManager.instance.primaryFocus?.unfocus();

      if (searchTextController.text.isEmpty) {
        showResultsController.update((state) => false);
      } else {
        showSearchLoaderController.update((state) => true);

        searchNotifierController
            .fetchSearchResults(
          context,
          searchTextController.text,
        )
            .then((value) {
          if (value.isEmpty) {
            showResultsController.update((state) => false);
          } else {
            showResultsController.update((state) => true);
          }

          showSearchLoaderController.update((state) => false);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Feeds'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text(
            //   'Search through feeds',
            //   style: TextStyle(
            //     fontSize: 16,
            //     fontWeight: FontWeight.w400,
            //   ),
            // ),
            const SizedBox(height: 5),
            TextField(
              controller: searchTextController,
              onSubmitted: (val) => searchFunction(),
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: searchFunction,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 5),
            showSearchLoader
                ? const LinearLoader()
                : !showResults
                    ? const Center(child: Text('No results'))
                    : Expanded(
                        child: Scrollbar(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: searchNotifier.length,
                            itemBuilder: (context, index) {
                              final newsItem = searchNotifier[index];
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
          ],
        ),
      ),
    );
  }
}
