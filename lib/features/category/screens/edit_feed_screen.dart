import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/common_widgets.dart';
import '../../../common/sizer.dart';
import '../../../components/app_back_button.dart';
import '../../../components/app_text_form_field.dart';
import '../repository/manage_category_repository.dart';

final isFeedTitleUpdatingProvider = StateProvider((ref) => false);

class EditFeedScreen extends HookConsumerWidget {
  static const routeNamed = '/edit-feed-screen';

  final String oldFeedTitle;
  final int feedId;
  final int catId;
  final BuildContext listContext;

  const EditFeedScreen({
    super.key,
    required this.oldFeedTitle,
    required this.feedId,
    required this.catId,
    required this.listContext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final newFeedTitleController = useTextEditingController();

    final isFeedTitleUpdating = ref.watch(isFeedTitleUpdatingProvider);
    final isFeedTitleUpdatingController =
        ref.watch(isFeedTitleUpdatingProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit $oldFeedTitle'),
        leading: AppBackButton(
          controller: isFeedTitleUpdating,
        ),
      ),
      body: isFeedTitleUpdating
          ? const LinearLoader()
          : Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppTextFormField(
                      controller: newFeedTitleController,
                      labelText: 'New Feed Title',
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Sizer(
        widthMobile: 0.95,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: ElevatedButton(
            onPressed: isFeedTitleUpdating
                ? null
                : () {
                    isFeedTitleUpdatingController.update((state) => true);

                    ref
                        .read(manageCateNotifierProvider.notifier)
                        .updateCatFeedName(
                          listContext: listContext,
                          feedId: feedId,
                          catId: catId,
                          newFeedTitle: newFeedTitleController.text,
                        )
                        .then(
                          (_) => isFeedTitleUpdatingController
                              .update((state) => false),
                        );
                  },
            child: const Text('Update'),
          ),
        ),
      ),
    );
  }
}
