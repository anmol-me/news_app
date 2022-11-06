import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:news_app/features/app_bar/user.dart';

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

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('BUILT');
    final formKey = GlobalKey<FormState>();
    final idController = useTextEditingController(text: '0');
    final nameController = useTextEditingController(text: 'Anmol');
    final ageController = useTextEditingController(text: '10');

    User? person1;

    final users = ref.watch(userNotifierProvider);
    final usersController = ref.watch(userNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Title'),
      ),
      body: Form(
        key: formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(controller: idController),
              TextFormField(controller: nameController),
              TextFormField(controller: ageController),
              TextButton(
                onPressed: () {
                  // person1 = User(
                  //   name: nameController.text,
                  //   age: int.parse(
                  //     ageController.text,
                  //   ),
                  // );

                  usersController.add(
                    int.parse(idController.text),
                    nameController.text,
                    int.parse(ageController.text),
                  );

                  final user = ref.read(userNotifierProvider);
                  log(user.length.toString());
                  log(user[0].name);
                },
                child: const Text('Add'),
              ),
              TextButton(
                onPressed: () {
                  usersController.update(
                    int.parse(idController.text),
                    nameController.text,
                    int.parse(ageController.text),
                  );

                  log('Updated');
                },
                child: const Text('Update'),
              ),
              TextButton(
                onPressed: () {
                  log(users[0].id.toString());
                  log(users[0].name);
                  log(users[0].age.toString());
                },
                child: const Text('Check'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum States { initial, loading, done }

class User {
  final int id;
  final String name;
  final int age;

  User({
    required this.id,
    required this.name,
    required this.age,
  });

  User copyWith({
    int? id,
    String? name,
    int? age,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        age: age ?? this.age,
      );
}

final userNotifierProvider = StateNotifierProvider<UserNotifier, List<User>>(
  (ref) => UserNotifier(),
);

class UserNotifier extends StateNotifier<List<User>> {
  UserNotifier() : super([]);

  void add(int id, String name, int age) {
    state = [...state, User(id: id, name: name, age: age)];
  }

  void update(int id, String name, int age) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(name: name, age: age) else item,
    ];
  }
}
