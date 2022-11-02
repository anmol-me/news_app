import 'package:flutter/material.dart';

class DisabledMoreButton extends StatelessWidget {
  const DisabledMoreButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          'More',
          style: TextStyle(
            fontSize: 17,
            color: Colors.grey,
          ),
        ),
        SizedBox(width: 5),
        Icon(
          Icons.arrow_forward,
          size: 16,
          color: Colors.grey,
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
      children: const [
        Icon(
          Icons.arrow_back,
          size: 16,
          color: Colors.grey,
        ),
        SizedBox(width: 5),
        Text(
          'Previous',
          style: TextStyle(
            fontSize: 17,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}