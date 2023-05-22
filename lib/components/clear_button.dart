import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/constants.dart';
import '../features/category/repository/category_repo.dart';
import '../features/home/providers/home_providers.dart';
import '../features/subscription/repository/subscription_repository.dart';

class ClearButton extends ConsumerWidget {
  final String? data;
  final void Function()? onPressed;

  const ClearButton({
    super.key,
    this.data,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        data ?? 'Clear',
        style: TextStyle(
          color: colorRed,
        ),
      ),
    );
  }
}

class AppRefreshButton extends ConsumerWidget {
  final IconData? icon;
  final void Function()? onPressed;

  const AppRefreshButton({
    super.key,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: onPressed,
      child: Icon(
        icon ?? Icons.refresh,
        color: colorRed,
      ),
    );
  }
}

class HomeClearButton extends ConsumerWidget {
  const HomeClearButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClearButton(
      onPressed: () => ref.refresh(homeFeedProvider),
    );
  }
}

class CategoryClearButton extends ConsumerWidget {
  final int catId;

  const CategoryClearButton({
    super.key,
    required this.catId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catNotifier = ref.watch(categoryNotifierProvider);

    return catNotifier.isNotEmpty
        ? ClearButton(
            onPressed: () => ref
                .read(categoryNotifierProvider.notifier)
                .clearOrRefreshDemo(catId, context),
          )
        : AppRefreshButton(
            onPressed: () => ref
                .read(categoryNotifierProvider.notifier)
                .clearOrRefreshDemo(catId, context),
          );
  }
}

class SubscriptionClearButton extends ConsumerWidget {
  const SubscriptionClearButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClearButton(
      onPressed: () =>
          ref.refresh(subscriptionNotifierProvider.notifier).clearState(),
    );
  }
}
