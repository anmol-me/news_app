import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../home/providers/home_providers.dart';
import '../../repository/category_list_repo.dart';
import '../category_screen.dart';

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

        /// Todo: Nav
        // Navigator.of(context).pushNamed(
        //   CategoryScreen.routeNamed,
        //   arguments: {
        //     'id': subscriptionItem.id,
        //     'catTitle': subscriptionItem.title,
        //     'isBackButton': false,
        //   },
        // );
      },
      child: ListTile(
        // leading: Text('${subscriptionItem.id}'),
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
