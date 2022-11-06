import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ErrorScreen extends ConsumerWidget {
  static const routeNamed = '/error-screen';

  final String message;

  const ErrorScreen({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('An error occurred!'),
      ),
      body: Center(
        child: Text(message),
      ),
    );
  }
}
