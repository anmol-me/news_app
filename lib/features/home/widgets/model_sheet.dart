import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/features/subscription/repository/category_list_repo.dart';

import '../../category/screens/manage_categories_screen.dart';
import '../../category/screens/show_category_feeds_screen.dart';
import '../../subscription/repository/add_new_subscription_repo.dart';
import '../../subscription/screens/edit_subscription_screen.dart';

Future showModelSheet({
  required BuildContext context,
  required CategoryList listItem,
  required WidgetRef ref,
}) {
  final categoryIdController = ref.read(categoryIdProvider.notifier);

  return showModalBottomSheet(
    context: context,
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
                Navigator.of(context).pushNamed(
                  EditSubscription.routeNamed,
                  arguments: {
                    'oldTitle': listItem.title,
                    'listItemId': listItem.id,
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
                categoryIdController.update((state) => listItem.id);

                Navigator.of(context).pushNamed(
                  ShowCategoryFeedsScreen.routeNamed,
                  arguments: {
                    'title': listItem.title,
                    // 'oldTitle': listItem.title,
                    // 'listItemId': listItem.id,
                  },
                );
              },
              text: 'Manage ${listItem.title}',
              fontSize: 18,
            ),
            customTile(
              context: context,
              onTap: () {
                ref.read(addNewSubscriptionProvider.notifier).deleteFeed(
                      context,
                      listItem.id,
                      listItem.title,
                    );
                // Will pop after.


              },
              text: 'Delete',
              fontSize: 18,
            ),
          ],
        ),
      ),
    ),
  );
}

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
            Navigator.of(context).pushNamed(
              EditSubscription.routeNamed,
              arguments: {
                'oldTitle': listItem.title,
                'listItemId': listItem.id,
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
    // color: Colors.grey,
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
