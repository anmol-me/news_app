import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/common_widgets/common_widgets.dart';
import 'package:news_app/features/home/screens/home_feed_screen.dart';
import 'package:news_app/features/search/repository/search_repo.dart';

import '../../../common/constants.dart';
import '../../home/providers/home_providers.dart';

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

    final showSearchLoader = ref.watch(showSearchLoaderProvider);

    final searchNotifier = ref.watch(searchNotifierProvider);
    final searchNotifierController = ref.watch(searchNotifierProvider.notifier);

    final newsNotifierController = ref.watch(homeFeedProvider.notifier);

    final scrollController = useScrollController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Feeds'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: searchTextController,
              onSubmitted: (val) => searchNotifierController.searchFunction(
                searchTextController,
                context,
              ),
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => searchNotifierController.searchFunction(
                    searchTextController,
                    context,
                  ),
                ),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1.5,
                    color: colorRed,
                  ),
                ),
                suffixIconColor: colorAppbarForeground,
              ),
            ),
            const SizedBox(height: 5),
            showSearchLoader
                ? const LinearLoader()
                : !showResults

                    /// Todo: List Empty Search
                    ? const Center(child: Text('No results'))
                    : Expanded(
                        child: Scrollbar(
                          controller: scrollController,
                          child: ListView.builder(
                            controller: scrollController,
                            shrinkWrap: true,
                            itemCount: searchNotifier.length,
                            itemBuilder: (context, index) {
                              final newsItem = searchNotifier[index];

                              return buildExpansionWidget(
                                'search',
                                newsItem,
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
