import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userPrefsProvider = Provider((ref) => UserPreferences());

class UserPreferences {
  static SharedPreferences? prefs;

  static const keyAuthData = 'authData';
  static const keyUrlData = 'urlData';
  static const keyUsername = 'username';

  static Future init() async => prefs = await SharedPreferences.getInstance();

  Future setAuthData(String authData) async {
    log('Prefs Auth set $authData');
    return await prefs!.setString(keyAuthData, authData);
  }

  String? getAuthData() {
    log('Prefs Auth get ${prefs!.getString(keyAuthData)}');
    return prefs?.getString(keyAuthData);
  }

  Future setUrlData(String urlData) async {
    return await prefs!.setString(keyUrlData, urlData);
  }

  String? getUrlData() => prefs!.getString(keyUrlData);

  Future setUsername(String username) async {
    log('Prefs user set $username');
    return await prefs!.setString(keyUsername, username);
  }

  String? getUsername() {
    log('Prefs user get ${prefs!.getString(keyUsername)}');
    return prefs?.getString(keyUsername);
  }

  void clearPrefs() => prefs?.clear();
}