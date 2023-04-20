import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/features/subscription/widgets/subscription_tile.dart';

import '../../../common/model_sheet.dart';
import '../../../models/model.dart';
import '../repository/subscription_repository.dart';
import '../screens/edit_subscription_screen.dart';

// Only for iOS and macOS
Slidable buildSlidable(
  CategoryList listItem,
  WidgetRef ref,
  BuildContext listContext,
) {
  return Slidable(
    direction: Axis.horizontal,

    /// End Pane
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
          },
          backgroundColor: const Color(0xFFFE4A49),
          foregroundColor: Colors.white,
          icon: CupertinoIcons.delete,
          label: 'Delete',
        ),
        SlidableAction(
          spacing: 6,
          onPressed: (context) {
            context.pushNamed(
              EditSubscriptionScreen.routeNamed,
              queryParams: {
                'oldTitle': listItem.title,
                'listItemId': listItem.id.toString(),
              },
            );
          },
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          icon: Icons.edit,
          label: 'Edit',
        ),
      ],
    ),

    /// Start Pane
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

    /// Slidable Child
    child: buildSubscriptionTile(
      listItem,
      ref,
      listContext,
    ),
  );
}

// All platforms except iOS and macOS
// For iOS and macOS, buildSlidable's Slidable widget wraps buildSubscriptionTile
SubscriptionTile buildSubscriptionTile(
  CategoryList subscriptionItem,
  WidgetRef ref,
  BuildContext listContext,
) =>
    SubscriptionTile(
      id: subscriptionItem.id,
      children: [
        IconButton(
          onPressed: () => showModelSheet(
            listContext: listContext,
            listItem: subscriptionItem,
            ref: ref,
          ),
          icon: const Icon(
            Icons.more_vert,
          ),
        ),
      ],
    );
