import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/common_widgets.dart';
import '../../category/repository/category_feed_repository.dart';

final isTitleUpdatingProvider = StateProvider((ref) => false);

class EditSubscription extends HookConsumerWidget {
  static const routeNamed = '/edit-subs';

  final String oldTitle;
  final int listItemId;

  const EditSubscription({
    super.key,
    required this.oldTitle,
    required this.listItemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final newTitleController = useTextEditingController();

    final catFeedRepo = ref.watch(catFeedRepoProvider.notifier);

    final isTitleUpdating = ref.watch(isTitleUpdatingProvider);
    final isTitleUpdatingController =
        ref.watch(isTitleUpdatingProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit $oldTitle'),
      ),
      body: isTitleUpdating
          ? const LinearLoader()
          : Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: newTitleController,
                      decoration: const InputDecoration(
                        labelText: 'New Title',
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        isTitleUpdatingController.update((state) => true);
                        catFeedRepo
                            .updateCatFeed(
                              context,
                              listItemId,
                              newTitleController.text,
                            )
                            .then(
                              (_) => isTitleUpdatingController
                                  .update((state) => false),
                            );
                      },
                      child: const Text('Update'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
