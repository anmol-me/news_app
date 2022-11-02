import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../error_screen.dart';
import '../features/authentication/repository/auth_repo.dart';
import '../features/authentication/screens/auth_screen.dart';

void navigateError(
    BuildContext context,
    String message,
    ) {
  Navigator.of(context).pushNamed(
    ErrorScreen.routeNamed,
    arguments: {'message': message},
  );
}

Future showErrorDialogue(
    BuildContext context, StateNotifierProviderRef ref, e) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('An Error Occurred!'),
      content: Text('$e'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: const Text('Take me back'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            ref.read(userPrefsProvider).clearPrefs();
            Navigator.of(context).pushNamed(AuthScreen.routeNamed);
          },
          child: const Text('Okay'),
        ),
      ],
    ),
  );
}