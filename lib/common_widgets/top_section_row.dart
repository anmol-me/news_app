import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../common/constants.dart';
import '../models/news.dart';
import '../features/subscription/screens/category_screen.dart';
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
            queryParams: {
              'id': newsItem.catId.toString(),
              'catTitle': newsItem.categoryTitle,
              'isBackButton': 'true',
            },
          );

          /// Todo: Nav
          // Navigator.of(context).pushNamed(
          //   CategoryScreen.routeNamed,
          //   arguments: {
          //     'id': newsItem.catId,
          //     'catTitle': newsItem.categoryTitle,
          //     'isBackButton': true,
          //   },
          // );
        },
        child: Text(
          newsItem.categoryTitle,
          style: TextStyle(
            color: colorRed,
            // fontSize: 15,
          ),
        ),
      ),
      Text(
        ' / ',
        style: TextStyle(
          color: Colors.grey[500],
          // fontSize: 15,
        ),
      ),
      Text(
        dateTime,
        style: TextStyle(
          color: Colors.grey[500],
          // fontSize: 15,
        ),
      ),
    ],
  );
}
