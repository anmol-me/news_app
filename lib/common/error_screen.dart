import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ErrorScreen extends HookConsumerWidget {
  static const routeNamed = '/error-screen';

  final String message;

  const ErrorScreen({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(
      () {
        FlutterNativeSplash.remove();
        return null;
      },
      [],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('An error occurred!'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Home'),
            ),
            const SizedBox(height: 10),
            Text(message),
          ],
        ),
      ),
    );
  }
}
