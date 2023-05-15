import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/subscription_repository.dart';
import '../../../common/constants.dart';

class SubscriptionRefreshButton extends ConsumerWidget {
  const SubscriptionRefreshButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () => ref
          .read(subscriptionNotifierProvider.notifier)
          .fetchDemoCategories(context),
      icon: Icon(
        Icons.refresh,
        color: colorRed,
      ),
    );
  }
}
