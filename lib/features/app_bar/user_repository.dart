import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/api_methods.dart';
import '../authentication/repository/user_preferences.dart';

/// User Model
class User {
  final String username;

  User({
    required this.username,
  });
}

/// Provider
final userNotifierProvider = NotifierProvider<UserNotifier, User?>(
  UserNotifier.new,
);

/// Notifier
class UserNotifier extends Notifier<User?> {
  late UserPreferences userPrefs;
  late String baseUrl;
  late String userPassEncoded;

  @override
  User build() {
    userPrefs = ref.watch(userPrefsProvider);
    baseUrl = userPrefs.getUrlData() ?? '';
    userPassEncoded = userPrefs.getAuthData() ?? '';
    return User(username: '');
  }

  Future<User> fetchUserData(BuildContext context) async {
    try {
      // Get username from server & save to cache
      String? username = ref.read(userPrefsProvider).getUsername();

      if (username == null || username.isEmpty) {
        final baseUrl = userPrefs.getUrlData() ?? '';
        final userPassEncoded = userPrefs.getAuthData() ?? '';

        Uri uri = Uri.https(baseUrl, 'v1/me');

        final res = await getHttpResp(uri, userPassEncoded);

        Map<String, dynamic> decodedData = jsonDecode(res.body);

        final currentUser = User(
          username: decodedData['username'],
        );

        userPrefs.setUsername(currentUser.username);
        return state = currentUser;
      } else {
        // Get username from cache
        return state = User(username: username);
      }
    } catch (e) {
      return state ?? User(username: '');
    }
  }

  Future<User> fetchDemoUserData(BuildContext context) async {
    try {
      return state = User(username: 'Demo User');
    } catch (_) {
      return User(username: '');
    }
  }
}
