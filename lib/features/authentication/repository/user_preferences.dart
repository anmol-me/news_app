import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userPrefsProvider = Provider((ref) => UserPreferences());

class UserPreferences {
  static SharedPreferences? prefs;

  static const keyAuthData = 'authData';
  static const keyIsAuthData = 'isAuth';
  static const keyIsDemoUser = 'isDemoUser';
  static const keyUrlData = 'urlData';
  static const keyUsername = 'username';

  static Future init() async => prefs = await SharedPreferences.getInstance();

  Future<bool> setIsDemo(bool isDemoUser) async {
    return await prefs!.setBool(keyIsDemoUser, isDemoUser);
  }

  bool? getIsDemo() {
    log('Prefs Demo get ${prefs!.getBool(keyIsDemoUser)}');
    return prefs?.getBool(keyIsDemoUser) ?? false;
  }

  Future<bool> setAuthData(String userPassEncoded) async {
    return await prefs!.setString(keyAuthData, userPassEncoded);
  }

  String? getAuthData() {
    log('-----------------------> ${prefs!.getString(keyAuthData)}');
    return prefs?.getString(keyAuthData);
  }

  Future<bool> setIsAuth(bool isAuth) async {
    log('SET: $isAuth');
    return await prefs!.setBool(keyIsAuthData, isAuth);
  }

  bool? getIsAuth() {
    log('GET: ${prefs!.getBool(keyIsAuthData)}');
    return prefs?.getBool(keyIsAuthData) ?? false;
  }

  Future<bool> setUrlData(String urlData) async {
    return await prefs!.setString(keyUrlData, urlData);
  }

  String? getUrlData() => prefs!.getString(keyUrlData);

  Future<bool> setUsername(String username) async {
    log('Prefs user set $username');
    return await prefs!.setString(keyUsername, username);
  }

  String? getUsername() {
    log('Prefs user get ${prefs!.getString(keyUsername)}');
    return prefs?.getString(keyUsername);
  }

  void clearPrefs() => prefs?.clear();
}
