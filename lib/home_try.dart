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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
