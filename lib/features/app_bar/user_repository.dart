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
      // Get username from cache
      String username = userPrefs.getUsername() ?? '';

      if (username.isNotEmpty) {
        return state = User(username: username);
      }

      // Else get username from server & save to cache
      Uri uri = Uri.https(baseUrl, 'v1/me');

      final res = await getHttpResp(uri, userPassEncoded);

      Map<String, dynamic> decodedData = jsonDecode(res.body);

      final currentUser = User(
        username: decodedData['username'],
      );

      userPrefs.setUsername(currentUser.username);

      return state = currentUser;
    } catch (e) {
      return state ?? User(username: '');
    }
  }
}