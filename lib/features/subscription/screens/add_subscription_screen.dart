import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/components/app_back_button.dart';

import '../../../common/common_widgets.dart';
import '../../../common/constants.dart';
import '../../../models/model.dart';
import '../repository/category_list_repo.dart';
import '../repository/add_new_subscription_repo.dart';
import '../widgets/add_category_sheet.dart';

/// Providers
final selectedCategoryProvider = StateProvider.autoDispose((ref) => '');

final isDiscoverLoadingProvider =
    StateProvider.autoDispose<bool>((ref) => false);

final showAsteriskProvider = StateProvider.autoDispose<bool>((ref) => false);

/// Class
class AddSubscription extends HookConsumerWidget {
  static const routeNamed = '/add-category';

  const AddSubscription({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    // final _formKey = useMemoized(GlobalKey<FormState>.new, const []);

    // final urlController =
    //     useTextEditingController(text: 'https://news.google.com');
    // final urlController = useTextEditingController(
    //     text: 'https://feeds.feedburner.com/TheHackersNews');

    final urlController = useTextEditingController(
        text: 'https://rss.art19.com/apology-line');
    final catNameController = useTextEditingController();

    // final catNewsNotifier = ref.watch(categoryNotifierProvider);
    // final catNewsNotifierController =
    //     ref.read(categoryNotifierProvider.notifier);

    final discoverSubscription = ref.watch(addNewSubscriptionProvider);
    final discoverSubscriptionController =
        ref.watch(addNewSubscriptionProvider.notifier);

    final isDiscoverLoading = ref.watch(isDiscoverLoadingProvider);

    final showAsterisk = ref.watch(showAsteriskProvider);

    final feedId = ref.watch(feedIdProvider);
    print('-------------> ${feedId} <------------------');

    // https://www.theverge.com/
    final selectedCategory = ref.watch(selectedCategoryProvider);

    List<CategoryList> categoryList = ref.watch(categoryListNotifierProvider);

    List<String> categoryTitles = categoryList.map((e) => e.title).toList();

    var selectedCatInfo = categoryList.firstWhere(
      (e) => e.title == selectedCategory,
      orElse: () => CategoryList(title: '', id: 0),
    );

    return
        Scaffold(
      appBar: AppBar(
        title: const Text('Add Subscription'),
        leading: AppBackButton(
          controller: isDiscoverLoading,
        ),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'RSS address',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                    showAsterisk
                        ? const Padding(
                            padding: EdgeInsets.only(right: 2.0),
                            child: Text(
                              '*',
                              style: TextStyle(color: Colors.red, fontSize: 17),
                            ),
                          )
                        : const SizedBox.shrink(),
                    DropdownButton<String>(
                      hint: const Text('Choose Category'),
                      items: categoryTitles
                          .map(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      value:
                          selectedCategory.isNotEmpty ? selectedCategory : null,
                      onChanged: (selected) {
                        ref.read(selectedCategoryProvider.notifier).update(
                              (state) => selected!,
                            );
                      },
                    ),
                    AddCatSheetButton(
                      catNameController: catNameController,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => discoverSubscriptionController
                    .discoverFunction(urlController, context),
                style: ElevatedButton.styleFrom(backgroundColor: colorRed),
                child: isDiscoverLoading
                    ? const CircularLoading()
                    : const Text('Discover'),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: discoverSubscription.isEmpty
                    ? const Text('Empty List')
                    : ListView.builder(
                        itemCount: discoverSubscription.length,
                        itemBuilder: (context, index) {
                          final subsItem = discoverSubscription[index];

                          return DiscoveryItem(
                            subsItem: subsItem,
                            selectedCatInfo: selectedCatInfo,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      // ),
    );
  }
}

class DiscoveryItem extends ConsumerStatefulWidget {
  final AddNewSubscription subsItem;
  final CategoryList selectedCatInfo;

  const DiscoveryItem({
    super.key,
    required this.subsItem,
    required this.selectedCatInfo,
  });

  @override
  ConsumerState createState() => _DiscoveryItemState();
}

class _DiscoveryItemState extends ConsumerState<DiscoveryItem> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    // final isDiscoveryItemsLoading = ref.watch(isDiscoveryItemsLoadingProvider);
    // final isDiscoveryItemsLoadingController =
    //     ref.watch(isDiscoveryItemsLoadingProvider.notifier);

    final selectedCategory = ref.watch(selectedCategoryProvider);

    final discoverSubscriptionController =
        ref.watch(addNewSubscriptionProvider.notifier);

    final activeCategory = ref.watch(selectedCategoryProvider);

    final showAsteriskController = ref.watch(showAsteriskProvider.notifier);

    /// Submit Feed
    void submitFeed() {
      if (selectedCategory.isEmpty) {
        showSnackBar(context: context, text: 'Please select category.');
        showAsteriskController.update((state) => true);
        return;
      } else if (selectedCategory.isNotEmpty) {
        showAsteriskController.update((state) => false);
      }

      setState(() => isLoading = true);

      discoverSubscriptionController
          .createFeed(
            context,
            activeCategory,
            widget.subsItem.url,
            widget.selectedCatInfo.id,
          )
          .then(
            (_) => setState(() => isLoading = false),
          );
    }

    return ListTile(
      title: Text(widget.subsItem.title),
      leading: isLoading
          ? CircularLoading(color: colorRed)
          : const Icon(Icons.circle),
      onTap: submitFeed,
    );
  }
}
