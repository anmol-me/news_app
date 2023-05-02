import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/components/app_back_button.dart';

import '../../../common/enums.dart';
import '../../../common_widgets/common_widgets.dart';
import '../../../common/constants.dart';
import '../../../models/model.dart';
import '../repository/subscription_repository.dart';
import '../repository/discovery_repository.dart';
import '../widgets/add_category_sheet.dart';

/// Providers
final selectedCategoryProvider = StateProvider.autoDispose((ref) => '');

final isDiscoverLoadingProvider =
    StateProvider.autoDispose<bool>((ref) => false);

final showAsteriskProvider = StateProvider.autoDispose<bool>((ref) => false);

final isFeedLoadingProvider = StateProvider.autoDispose((ref) => false);

/// Class
class AddSubscription extends HookConsumerWidget {
  static const routeNamed = '/add-category';

  const AddSubscription({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    final textFocus = useState(false);

    final showAsterisk = ref.watch(showAsteriskProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    ref.listen(selectedCategoryProvider, (_, String nextSelectedCategory) {
      if (showAsterisk == true && nextSelectedCategory != '') {
        ref.read(showAsteriskProvider.notifier).update((state) => false);
      }
    });

    /// Todo: New Subs Addresses
    // final urlController =
    //     useTextEditingController(text: 'https://news.google.com');
    // final urlController = useTextEditingController(
    //     text: 'https://feeds.feedburner.com/TheHackersNews');

    final urlController =
        useTextEditingController(text: 'https://rss.art19.com/apology-line');
    final catNameController = useTextEditingController();

    final discoverSubscription = ref.watch(discoveryProvider);
    final discoverSubscriptionController =
        ref.watch(discoveryProvider.notifier);

    final isDiscoverLoading = ref.watch(isDiscoverLoadingProvider);

    final isFeedLoading = ref.watch(isFeedLoadingProvider);

    List<CategoryList> categoryList = ref.watch(subscriptionNotifierProvider);

    List<String> categoryTitles = categoryList.map((e) => e.title).toList();

    var selectedCatInfo = categoryList.firstWhere(
      (e) => e.title == selectedCategory,
      orElse: () => CategoryList(title: '', id: 0),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Subscription'),
        leading: AppBackButton(
          controller: isDiscoverLoading || isFeedLoading,
        ),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Focus(
                onFocusChange: (hasFocus) {
                  hasFocus ? textFocus.value = true : textFocus.value = false;
                },
                child: TextFormField(
                  controller: urlController,
                  decoration: InputDecoration(
                    labelText: 'RSS address',
                    labelStyle: TextStyle(
                      color: textFocus.value ? colorRed : colorAppbarForeground,
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
                  validator: (val) {
                    if (urlController.text.isEmpty) {
                      return ErrorString.emptyField.value;
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  top: 5,
                  bottom: 5,
                ),
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
                onPressed: () =>
                    discoverSubscriptionController.discoverFunction(
                  urlController,
                  formKey,
                  context,
                ),
                style: ElevatedButton.styleFrom(backgroundColor: colorRed),
                child: isDiscoverLoading
                    ? const CircularLoading()
                    : const Text('Discover'),
              ),
              const SizedBox(height: 15),
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

class DiscoveryItem extends HookConsumerWidget {
  final DiscoverSubscription subsItem;
  final CategoryList selectedCatInfo;

  const DiscoveryItem({
    super.key,
    required this.subsItem,
    required this.selectedCatInfo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);

    final discoveryNotifier = ref.watch(discoveryProvider.notifier);

    return ListTile(
      title: Text(subsItem.title),
      leading: isLoading.value
          ? CircularLoading(color: colorRed)
          : const Icon(Icons.circle),
      onTap: () => discoveryNotifier.submitFeed(
        context,
        isLoading,
        subsItem,
        selectedCatInfo,
      ),
    );
  }
}
