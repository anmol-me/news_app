import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
          GestureDetector(
            onTap: () => !isLoadingSubs
                ? context.pushNamed(AddSubscription.routeNamed)
                : null,
            child: Image.asset(
              'assets/images/add_items.png',
              width: 230,
              height: 230,
              fit: BoxFit.contain,
              opacity: const AlwaysStoppedAnimation(0.9),
            ),
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
