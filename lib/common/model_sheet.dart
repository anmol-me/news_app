import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/features/subscription/repository/subscription_repository.dart';

import '../common_widgets/common_widgets.dart';
import '../features/authentication/repository/user_preferences.dart';
import '../features/category/screens/manage_category_screen.dart';
import '../features/subscription/screens/edit_subscription_screen.dart';
import '../models/model.dart';
import 'enums.dart';

Future showModelSheet({
  required CategoryList listItem,
  required WidgetRef ref,
  required BuildContext listContext,
}) =>
    showModalBottomSheet(
      context: listContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.only(top: 15),
        child: SizedBox(
          height: MediaQuery.of(context).copyWith().size.height * 0.35,
          child: ListView(
            children: [
              customTile(
                context: context,
                onTap: () {
                  Navigator.of(context).pop();

                  context.pushNamed(
                    EditSubscriptionScreen.routeNamed,
                    queryParameters: {
                      'oldTitle': listItem.title,
                      'listItemId': listItem.id.toString(),
                    },
                  );
                },
                text: 'Edit',
                fontSize: 18,
              ),
              customTile(
                context: context,
                onTap: () {
                  Navigator.of(context).pop();

                  final isDemoPref =
                      ref.read(userPrefsProvider).getIsDemo() ?? false;
                  if (isDemoPref) {
                    showErrorSnackBar(
                        context: context,
                        text: ErrorString.demoManageCategory.value);
                    return;
                  }

                  context.pushNamed(
                    ManageCategoryScreen.routeNamed,
                    queryParameters: {
                      'catListItemId': listItem.id.toString(),
                      'catListItemTitle': listItem.title,
                    },
                  );
                },
                text: 'Manage ${listItem.title}',
                fontSize: 18,
              ),
              customTile(
                context: context,
                onTap: () {
                  Navigator.of(context).pop();

                  final isDemoPref =
                      ref.read(userPrefsProvider).getIsDemo() ?? false;
                  if (!isDemoPref) {
                    ref
                        .read(isDeletingCatProvider.notifier)
                        .update((state) => true);

                    ref
                        .read(subscriptionNotifierProvider.notifier)
                        .deleteCategory(
                          listContext,
                          listItem.id,
                          listItem.title,
                        )
                        .then(
                          (_) => ref
                              .read(isDeletingCatProvider.notifier)
                              .update((state) => false),
                        );
                  } else {
                    // Demo
                    ref
                        .read(subscriptionNotifierProvider.notifier)
                        .deleteDemoCategory(
                          listItem.id,
                          listItem.title,
                          context,
                        );
                  }
                },
                text: 'Delete',
                fontSize: 18,
              ),
            ],
          ),
        ),
      ),
    );

Future showCupertinoSheet(
  BuildContext context,
  CategoryList listItem,
) {
  return showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: const Text('Choose Options'),
      message: const Text('Your options are '),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: const Text('Edit'),
          onPressed: () {
            context.pushNamed(
              EditSubscriptionScreen.routeNamed,
              queryParameters: {
                'oldTitle': listItem.title,
                'listItemId': listItem.id.toString(),
              },
            );
          },
        ),
        CupertinoActionSheetAction(
          child: const Text('Delete'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    ),
  );
}

Widget customTile({
  required context,
  required VoidCallback onTap,
  required String text,
  required double fontSize,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(
      vertical: 4,
      horizontal: 10,
    ),
    width: MediaQuery.of(context).size.width - 10,
    child: InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.centerLeft,
        height: 40,
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize),
        ),
      ),
    ),
  );
}
