import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/models/user.dart';

import '../features/authentication/repository/auth_repo.dart';

final userNotifierProvider =
    StateNotifierProvider<UserNotifier, List<User>>((ref) {
      final userPrefs = ref.watch(userPrefsProvider);

      return UserNotifier(userPrefs);
    });

final userNotifierFuture =
    FutureProvider.family<dynamic, BuildContext>((ref, context) {

  final userNotifier = ref.read(userNotifierProvider.notifier);
  return userNotifier.fetchUserData(context);
});
