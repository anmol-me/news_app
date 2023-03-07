import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final catSortProvider = StateProvider<String>((ref) => 'asc');

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Checker(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('*** BUILT ***');
    final catSort = ref.watch(catSortProvider);
    final catSortController = ref.read(catSortProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          IconButton(
              onPressed: () {
                if (catSort == 'asc') {
                  catSortController.update((state) => 'desc');
                }
                log('UPDATED TO ${ref.watch(catSortProvider)}');
              },
              icon: const Icon(Icons.remove)),
          IconButton(
              onPressed: () {
                if (catSort == 'desc') {
                  catSortController.update((state) => 'asc');
                }
                log('UPDATED TO ${ref.watch(catSortProvider)}');
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [],
        ),
      ),
    );
  }
}

class Checker extends ConsumerStatefulWidget {
  const Checker({super.key});

  @override
  ConsumerState createState() => _CheckerState();
}

class _CheckerState extends ConsumerState<Checker> {
  @override
  Widget build(BuildContext context) {
    log('*** BUILT ***');
    final catSort = ref.watch(catSortProvider);
    final catSortController = ref.watch(catSortProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {});
                log('State refreshed.');
              },
              icon: const Icon(Icons.refresh)),
          IconButton(
              onPressed: () {
                // final catSortController = ref.read(catSortProvider.notifier);
                if (catSort == 'asc') {
                  catSortController.update((state) => 'desc');
                }
                log('UPDATED TO ${ref.watch(catSortProvider)}');
              },
              icon: const Icon(Icons.remove)),
          IconButton(
              onPressed: () {
                // final catSortController = ref.read(catSortProvider.notifier);
                if (catSort == 'desc') {
                  catSortController.update((state) => 'asc');
                }
                log('UPDATED TO ${ref.watch(catSortProvider)}');
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${ref.watch(catSortProvider)}'),
          ],
        ),
      ),
    );
  }
}
