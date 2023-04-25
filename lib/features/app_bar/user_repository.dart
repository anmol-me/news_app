import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/backend_methods.dart';
import '../authentication/repository/user_preferences.dart';

/// User Model
class User {
  final int id;
  final String username;

  User({
    required this.id,
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
    return User(id: 0, username: 'loading...');
  }

  Future<User> fetchUserData(BuildContext context) async {
    try {
      Uri uri = Uri.https(baseUrl, 'v1/me');

      final res = await getHttpResp(uri, userPassEncoded);

      Map<String, dynamic> decodedData = jsonDecode(res.body);

      final currentUser = User(
        id: decodedData['id'],
        username: decodedData['username'],
      );

      return state = currentUser;
    } catch (e) {
      return state ?? User(id: 0, username: 'Loading');
    }
  }
}
