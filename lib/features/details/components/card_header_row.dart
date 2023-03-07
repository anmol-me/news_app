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
          style: TextStyle(
            color: colorRed,
            fontSize: 15,
          ),
        ),
        Text(
          ' / ',
          style: TextStyle(
            color: colorSubtitle,
            fontSize: 15,
          ),
        ),
        Text(
          '$feedDate at $feedTime',
          style: TextStyle(
            color: colorSubtitle,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
