import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/repository/user_preferences.dart';
import 'error_screen.dart';
import '../features/authentication/screens/auth_screen.dart';

Future<Object?> navigateError(
  BuildContext context,
  String message,
) {
  return context.pushNamed(
    ErrorScreen.routeNamed,
    queryParameters: {'message': message},
  );
}

Future showErrorDialogue(
  BuildContext context,
  Ref ref,
  dynamic message,
) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('An Error Occurred!'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            ref.read(userPrefsProvider).clearPrefs();
            context.goNamed(AuthScreen.routeNamed);
          },
          child: const Text('Logout'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: const Text('Okay'),
        ),
      ],
    ),
  );
}
