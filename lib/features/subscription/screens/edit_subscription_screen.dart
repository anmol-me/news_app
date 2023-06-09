import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/constants.dart';
import '../../../common_widgets/common_widgets.dart';
import '../../../common/sizer.dart';
import '../../../components/app_back_button.dart';
import '../../../components/app_text_form_field.dart';
import '../../authentication/repository/user_preferences.dart';
import '../repository/subscription_repository.dart';

/// Providers
final isTitleUpdatingProvider = StateProvider((ref) => false);

/// Widget
class EditSubscriptionScreen extends HookConsumerWidget {
  static const routeNamed = '/edit-subs-screen';

  final String oldTitle;
  final int listItemId;

  const EditSubscriptionScreen({
    super.key,
    required this.oldTitle,
    required this.listItemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final newTitleController = useTextEditingController();
    final titleFocus = useState(false);

    final isTitleUpdating = ref.watch(isTitleUpdatingProvider);
    final isTitleUpdatingController =
        ref.watch(isTitleUpdatingProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit $oldTitle'),
        leading: AppBackButton(
          controller: isTitleUpdating,
        ),
      ),
      body: isTitleUpdating
          ? const LinearLoader()
          : Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Focus(
                      onFocusChange: (hasFocus) {
                        hasFocus
                            ? titleFocus.value = true
                            : titleFocus.value = false;
                      },
                      child: AppTextFormField(
                        controller: newTitleController,
                        labelText: 'New Title',
                        labelStyle: TextStyle(
                          color: titleFocus.value
                              ? colorRed
                              : colorAppbarForeground,
                        ),
                      ),
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
            onPressed: isTitleUpdating
                ? null
                : () {
                    final isDemoPref =
                        ref.read(userPrefsProvider).getIsDemo() ?? false;

                    if (!isDemoPref) {
                      isTitleUpdatingController.update((state) => true);

                      ref
                          .read(subscriptionNotifierProvider.notifier)
                          .updateCategoryName(
                            context,
                            formKey,
                            listItemId,
                            newTitleController.text,
                          )
                          .then(
                            (_) => isTitleUpdatingController
                                .update((state) => false),
                          );
                    } else {
                      ref
                          .read(subscriptionNotifierProvider.notifier)
                          .updateDemoCategoryName(
                            context,
                            formKey,
                            newTitleController.text,
                            oldTitle,
                          );
                    }
                  },
            child: const Text('Update'),
          ),
        ),
      ),
    );
  }
}
