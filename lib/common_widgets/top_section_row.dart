import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../common/constants.dart';
import '../models/news.dart';
import '../features/category/screens/category_screen.dart';
import '../features/home/providers/home_providers.dart';

Widget topSectionRow(
  News newsItem,
  String dateTime,
  WidgetRef ref,
  BuildContext context,
) {
  return Row(
    children: [
      GestureDetector(
        onTap: () {
          ref.refresh(homeOffsetProvider.notifier).update((state) => 0);
          ref.refresh(homeSortDirectionProvider).value;
          ref.refresh(isStarredProvider.notifier).update((state) => false);
          ref.refresh(homeIsShowReadProvider.notifier).update((state) => false);

          context.pushNamed(
            CategoryScreen.routeNamed,
            queryParameters: {
              'id': newsItem.catId.toString(),
              'catTitle': newsItem.categoryTitle,
              'isBackButton': 'true',
            },
          );
        },
        child: Text(
          newsItem.categoryTitle,
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: colorRed,
              ),
        ),
      ),
      Text(
        ' / ',
        style: Theme.of(context).textTheme.labelLarge,
      ),
      Text(
        dateTime,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    ],
  );
}
