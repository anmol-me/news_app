import 'package:flutter/material.dart';

import '../../../common/constants.dart';
import '../../subscription/screens/select_subscription_screen/select_subscription_screen.dart';

class WelcomeViewWidget extends StatelessWidget {
  const WelcomeViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Welcome to News Feed',
            style: TextStyle(
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Add feeds to get started',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorRed,
              ),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(SelectSubscriptionScreen.routeNamed);
              },
              child: const Text(
                'Add Subscription',
              ),
            ),
          ),
        ],
      ),
    );
  }
}