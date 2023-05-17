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
  const CategoryClearButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClearButton(
      onPressed: () =>
          ref.refresh(categoryNotifierProvider.notifier).clearCategoryState(),
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
