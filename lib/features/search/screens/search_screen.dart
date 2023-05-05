import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/common_widgets/common_widgets.dart';
import 'package:news_app/features/home/screens/home_feed_screen.dart';
import 'package:news_app/features/search/components/first_search_widget.dart';
import 'package:news_app/features/search/components/no_search_results.dart';
import 'package:news_app/features/search/repository/search_repo.dart';

import '../../home/providers/home_providers.dart';
import '../components/search_text_field.dart';

/// Providers
final showNoResultsProvider = StateProvider.autoDispose((ref) => false);

final showSearchLoaderProvider = StateProvider((ref) => false);

final showFirstSearchProvider = StateProvider((ref) => true);

/// Widgets
class SearchScreen extends HookConsumerWidget {
  static const routeNamed = '/search-screen';

  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final searchTextController = useTextEditingController();

    final showFirstSearch = ref.watch(showFirstSearchProvider);

    useEffect(
      () {
        if (!showFirstSearch) {
          Future.delayed(Duration.zero).then(
            (_) => ref
                .read(showFirstSearchProvider.notifier)
                .update((state) => true),
          );
        }
        return null;
      },
      [],
    );

    final showNoResults = ref.watch(showNoResultsProvider);

    final showSearchLoader = ref.watch(showSearchLoaderProvider);

    final searchNotifier = ref.watch(searchNotifierProvider);

    final newsNotifierController = ref.watch(homeFeedProvider.notifier);

    final scrollController = useScrollController();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Search Feeds'),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SearchTextField(
                searchTextController: searchTextController,
                formKey: formKey,
              ),
              const SizedBox(height: 5),
              showFirstSearch
                  ? const FirstSearchWidget()
                  : showSearchLoader
                      ? const LinearLoader()
                      : showNoResults
                          ? const NoSearchResultsWidget()
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
      ),
    );
  }
}
