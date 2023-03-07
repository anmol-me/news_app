import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/features/subscription/screens/select_subscription_screen/select_subscription_screen.dart';

import '../../../../common/model_sheet.dart';
import '../../../../models/model.dart';
import '../../repository/category_list_repo.dart';
import '../edit_subscription_screen.dart';

Slidable buildSlidable(
  CategoryList listItem,
  WidgetRef ref,
  BuildContext listContext,
) {
  return Slidable(
    direction: Axis.horizontal,
    endActionPane: ActionPane(
      extentRatio: 0.6,
      motion: const StretchMotion(),
      children: [
        SlidableAction(
          onPressed: (context) {
            showCupertinoSheet(
              context,
              listItem,
            );
          },
          backgroundColor: Colors.deepOrangeAccent,
          foregroundColor: Colors.white,
          icon: Icons.more_horiz,
          label: 'More',
        ),
        SlidableAction(
          spacing: 6,
          onPressed: (context) {
            ref.read(isDeletingCatProvider.notifier).update((state) => true);

            ref
                .read(categoryListNotifierProvider.notifier)
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
          },
          backgroundColor: const Color(0xFFFE4A49),
          foregroundColor: Colors.white,
          icon: CupertinoIcons.delete,
          label: 'Delete',
        ),
        SlidableAction(
          spacing: 6,
          onPressed: (context) {
            // ref
            //     .read(scaffoldKeyProvider.notifier)
            //     .update((state) => currentContext);

            context.pushNamed(
              EditSubscriptionScreen.routeNamed,
              queryParams: {
                'oldTitle': listItem.title,
                'listItemId': listItem.id.toString(),
              },
            );

            /// Todo: Nav
            // Navigator.of(context).pushNamed(
            //   EditSubscriptionScreen.routeNamed,
            //   arguments: {
            //     'oldTitle': listItem.title,
            //     'listItemId': listItem.id,
            //   },
            // );
          },
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          icon: Icons.edit,
          label: 'Edit',
        ),
      ],
    ),
    startActionPane: ActionPane(
      motion: const ScrollMotion(),
      children: [
        SlidableAction(
          onPressed: (context) {
            /// Todo:
          },
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          icon: Icons.archive,
          label: 'Archive',
        ),
      ],
    ),
    child: buildSubscriptionTile(
      listItem,
      ref,
      listContext,
    ),
  );
}
