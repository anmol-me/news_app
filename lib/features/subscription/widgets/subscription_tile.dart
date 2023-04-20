import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../home/providers/home_providers.dart';
import '../repository/subscription_repository.dart';
import '../../category/screens/category_screen.dart';

class SubscriptionTile extends ConsumerWidget {
  final int id;
  final List<Widget> children;

  const SubscriptionTile({
    super.key,
    required this.id,
    required this.children,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryListNotifier = ref.watch(categoryListNotifierProvider);

    final subscriptionItem = categoryListNotifier.firstWhere((e) => e.id == id);

    return InkWell(
      onTap: () {
        ref.refresh(homeOffsetProvider.notifier).update((state) => 0);
        ref.refresh(homeSortDirectionProvider).value;
        ref.refresh(isStarredProvider.notifier).update((state) => false);
        ref.refresh(homeIsShowReadProvider.notifier).update((state) => false);

        context.pushNamed(
          CategoryScreen.routeNamed,
          queryParams: {
            'id': subscriptionItem.id.toString(),
            'catTitle': subscriptionItem.title,
            'isBackButton': 'false',
          },
        );
      },
      child: ListTile(
        title: Text(subscriptionItem.title),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: children,
          ),
        ),
      ),
    );
  }
}
