import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/common_widgets.dart';
import '../../../common/constants.dart';
import '../../../models/model.dart';
import '../category_providers.dart';
import '../repository/category_list_repo.dart';
import '../repository/add_new_subscription_repo.dart';
import '../widgets/add_category_sheet.dart';

final selectedCategoryProvider = StateProvider.autoDispose((ref) => '');

final isDiscoverLoadingProvider = StateProvider<bool>((ref) => false);

// final isCategorySelectedProvider = StateProvider<bool>((ref) => false);
final showAsteriskProvider = StateProvider.autoDispose<bool>((ref) => false);

class AddSubscription extends HookConsumerWidget {
  static const routeNamed = '/add-category';

  const AddSubscription({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    // final _formKey = useMemoized(GlobalKey<FormState>.new, const []);

    // final urlController =
    //     useTextEditingController(text: 'https://news.google.com');
    final urlController =
        useTextEditingController(text: 'https://feeds.feedburner.com/TheHackersNew');
    final catNameController = useTextEditingController();

    // final catNewsNotifier = ref.watch(categoryNotifierProvider);
    // final catNewsNotifierController =
    //     ref.read(categoryNotifierProvider.notifier);

    final discoverSubscription = ref.watch(addNewSubscriptionProvider);
    final discoverSubscriptionController =
        ref.watch(addNewSubscriptionProvider.notifier);

    final isDiscoverLoading = ref.watch(isDiscoverLoadingProvider);
    final isDiscoverLoadingController =
        ref.watch(isDiscoverLoadingProvider.notifier);

    // final isCategorySelected = ref.watch(isCategorySelectedProvider);
    // final isCategorySelectedController =
    //     ref.watch(isCategorySelectedProvider.notifier);

    final showAsterisk = ref.watch(showAsteriskProvider);

    final feedId = ref.watch(feedIdProvider);

    // fetchCategoriesController.getCategories();

    // https://www.theverge.com/
    final selectedCategory = ref.watch(selectedCategoryProvider);

    List<CategoryList> categoryList = ref.watch(categoryListNotifierProvider);

    List<String> categoryTitles = categoryList.map((e) => e.title).toList();

    var selectedCatInfo = categoryList.firstWhere(
      (e) => e.title == selectedCategory,
      orElse: () => CategoryList(title: '', id: 0),
    );

    // log('LIST: $categoryTitles');

    void discoverFunction() {
      if (urlController.text.isEmpty) {
        showSnackBar(context: context, text: 'Please check Url.');
        return;
      }

      isDiscoverLoadingController.update((state) => true);

      discoverSubscriptionController
          .discover(
            urlController.text,
            context,
          )
          .then(
            (_) => isDiscoverLoadingController.update((state) => false),
          );
    }

    return
      // WillPopScope(
      // onWillPop: () async {
      //   log('Discovered cleared');
      //   discoverSubscription.clear();
      //   return await Future.value(true);
      // },
      // child:
      Scaffold(
        appBar: AppBar(
          title: const Text('Add Subscription'),
        ),
        body: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
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
                                style:
                                    TextStyle(color: Colors.red, fontSize: 17),
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
                        value: selectedCategory.isNotEmpty
                            ? selectedCategory
                            : null,
                        onChanged: (selected) {
                          ref.read(selectedCategoryProvider.notifier).update(
                                (state) => selected!,
                              );
                        },
                      ),
                      // IconButton(
                      //   onPressed: () {
                      //     showAddCategorySheet(context, ref, catNameController);
                      //   },
                      //   icon: const Icon(Icons.add),
                      // ),
                      AddCatSheetButton(
                        catNameController: catNameController,
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: discoverFunction,
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
