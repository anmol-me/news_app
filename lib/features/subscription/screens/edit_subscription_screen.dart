import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:news_app/common/constants.dart';

import '../repository/add_new_subscription_repo.dart';

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

    final subscriptionRepo = ref.watch(addNewSubscriptionProvider.notifier);

    final isTitleUpdating = ref.watch(isTitleUpdatingProvider);
    final isTitleUpdatingController = ref.watch(isTitleUpdatingProvider.state);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit $oldTitle'),
      ),
      body: isTitleUpdating
          ? LinearProgressIndicator(
              color: colorRed,
              backgroundColor: colorAppbarBackground,
            )
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
                        subscriptionRepo
                            .updateFeed(
                              context,
                              listItemId,
                              newTitleController.text,
                            )
                            .then((value) => isTitleUpdatingController
                                .update((state) => false));
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
