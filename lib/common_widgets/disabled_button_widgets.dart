import 'package:flutter/material.dart';
import 'package:news_app/common/constants.dart';

class DisabledMoreButton extends StatelessWidget {
  const DisabledMoreButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'More',
          style: TextStyle(
            fontSize: 17,
            color: colorDisabled,
          ),
        ),
        const SizedBox(width: 5),
        Icon(
          Icons.arrow_forward,
          size: 16,
          color: colorDisabled,
        ),
      ],
    );
  }
}

class DisabledPreviousButton extends StatelessWidget {
  const DisabledPreviousButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.arrow_back,
          size: 16,
          color: colorDisabled,
        ),
        const SizedBox(width: 5),
        Text(
          'Previous',
          style: TextStyle(
            fontSize: 17,
            color: colorDisabled,
          ),
        ),
      ],
    );
  }
}