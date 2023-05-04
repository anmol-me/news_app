import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/common_widgets/app_image.dart';

import '../screens/add_subscription_screen.dart';
import '../screens/select_subscription_screen.dart';

class ClearSubscriptionWidget extends ConsumerWidget {
  const ClearSubscriptionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoadingSubs = ref.watch(isLoadingSubsProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppImage(
            'assets/images/add_items.png',
            onTap: () => !isLoadingSubs
                ? context.pushNamed(AddSubscription.routeNamed)
                : null,
          ),
          const Text(
            'Add subscription to get started',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
