import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/features/app_bar/user.dart';

import '../authentication/repository/auth_repo.dart';

final userNotifierProvider =
StateNotifierProvider<UserNotifier, User?>((ref) {
  final userPrefs = ref.watch(userPrefsProvider);
  final baseUrl = userPrefs.getUrlData();
  final userPassEncoded = userPrefs.getAuthData();

  return UserNotifier(
    userPrefs,
    baseUrl!,
    userPassEncoded!,
    ref,
  );
});

final userNotifierFuture =
FutureProvider.family<dynamic, BuildContext>((ref, context) {
  final userNotifier = ref.read(userNotifierProvider.notifier);
  return userNotifier.fetchUserData(context);
});
