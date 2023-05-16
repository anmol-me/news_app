import 'package:flutter/material.dart';

import '../../../common/constants.dart';

class CardHeaderRow extends StatelessWidget {
  const CardHeaderRow({
    super.key,
    required this.categoryTitle,
    required this.feedDate,
    required this.feedTime,
  });

  final String categoryTitle;
  final String feedDate;
  final String feedTime;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Text(
          categoryTitle,
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: colorRed,
              ),
        ),
        Text(
          ' / ',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Text(
          '$feedDate at $feedTime',
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );
  }
}
