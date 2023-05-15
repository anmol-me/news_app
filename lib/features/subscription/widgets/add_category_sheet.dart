import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/components/app_text_form_field.dart';
import 'package:news_app/features/subscription/repository/subscription_repository.dart';
import '../../../common/enums.dart';
import '../../../common_widgets/common_widgets.dart';
import '../../../common/constants.dart';
import '../../authentication/repository/user_preferences.dart';

class AddCatSheetButton extends ConsumerWidget {
  final TextEditingController catNameController;

  const AddCatSheetButton({
    super.key,
    required this.catNameController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isLoading = false;
    bool titleFocus = false;

    final mediaQuery = MediaQuery.of(context);

    void createCategory(StateSetter setState) {
      final categoryListController =
          ref.read(subscriptionNotifierProvider.notifier);

      final isDemoPref = ref.read(userPrefsProvider).getIsDemo() ?? false;
      if (!isDemoPref) {
        setState(() => isLoading = true);

        categoryListController
            .createCategory(
          catNameController.text,
          context,
        )
            .then((_) {
          setState(() => isLoading = false);
          catNameController.clear();
        });
      } else {
        categoryListController
            .createDemoCategory(
          catNameController.text,
          context,
        )
            .then((_) {
          catNameController.clear();
        });
      }
    }

    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () {
        showModalBottomSheet(
          isDismissible: false,
          enableDrag: false,
          isScrollControlled: true,
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(15),
            ),
          ),
          builder: (context) => StatefulBuilder(
            builder: (BuildContext context, StateSetter set) {
              return Padding(
                padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: mediaQuery.size.height * 0.45,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Focus(
                          onFocusChange: (hasFocus) {
                            if (hasFocus) {
                              set(() {
                                titleFocus = true;
                              });
                            } else {
                              set(() {
                                titleFocus = false;
                              });
                            }
                          },
                          child: AppTextFormField(
                            controller: catNameController,
                            labelText: 'Category Name',
                            labelStyle: TextStyle(
                              color:
                                  titleFocus ? colorRed : colorAppbarForeground,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorRed,
                                ),
                                onPressed: () => createCategory(set),
                                child: isLoading
                                    ? const CircularLoading()
                                    : const Text('Create Category'),
                              ),
                            ),
                            isLoading
                                ? TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: colorDisabled,
                                    ),
                                    onPressed: null,
                                    child: const Text('Close'),
                                  )
                                : TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: colorRed,
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Close'),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
