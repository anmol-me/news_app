import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/constants.dart';
import '../common/enums.dart';
import '../features/home/providers/home_providers.dart';
import '../features/subscription/repository/category_repo.dart';
import '../main.dart';

class BuildPopupMenuButton extends ConsumerWidget {
  final bool isShowRead;
  final Sort sort;
  final void Function() sortFunction;
  final void Function() readFunction;

  const BuildPopupMenuButton({
    super.key,
    required this.isShowRead,
    required this.sort,
    required this.sortFunction,
    required this.readFunction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCatLoading = ref.watch(isCatLoadingProvider);
    final isHomeLoading = ref.watch(homeIsLoadingBookmarkProvider);
    final isHomeLoadingPage = ref.watch(homePageLoadingProvider);

    final themeMode = ref.watch(themeModeProvider);

    final filterColor =
        themeMode == ThemeMode.dark ? Colors.white : Colors.black;

    return PopupMenuButton<DropItems>(
      icon: Icon(
        Icons.filter_alt,
        color: isShowRead || sort == Sort.ascending
            ? colorRed
            : colorAppbarForeground,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: DropItems.sort,
          child: Row(
            children: [
              Icon(
                sort == Sort.ascending
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: filterColor,
              ),
              const SizedBox(width: 10),
              Text(
                sort == Sort.ascending
                    ? 'Switch to Latest'
                    : 'Switch to Oldest',
                style: TextStyle(
                  color: filterColor,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: DropItems.read,
          child: Row(
            children: [
              Icon(
                Icons.circle_outlined,
                color: filterColor,
              ),
              const SizedBox(width: 10),
              Text(
                isShowRead ? 'Show All' : 'Show Read',
                style: TextStyle(
                  color: filterColor,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (selected) {
        if (isCatLoading || isHomeLoading || isHomeLoadingPage) {
          null;
        } else if (selected == DropItems.sort) {
          sortFunction();
        } else if (selected == DropItems.read) {
          readFunction();
        }
      },
    );
  }
}