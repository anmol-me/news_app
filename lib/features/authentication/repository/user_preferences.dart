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

  bool? getIsDemo() => prefs?.getBool(keyIsDemoUser) ?? false;

  Future<bool> setAuthData(String userPassEncoded) async {
    return await prefs!.setString(keyAuthData, userPassEncoded);
  }

  String? getAuthData() => prefs?.getString(keyAuthData);

  Future<bool> setIsAuth(bool isAuth) async => await prefs!.setBool(keyIsAuthData, isAuth);

  bool? getIsAuth() => prefs?.getBool(keyIsAuthData) ?? false;

  Future<bool> setUrlData(String urlData) async => await prefs!.setString(keyUrlData, urlData);

  String? getUrlData() => prefs!.getString(keyUrlData);

  Future<bool> setUsername(String username) async => await prefs!.setString(keyUsername, username);

  String? getUsername() => prefs?.getString(keyUsername);

  void clearPrefs() => prefs?.clear();
}
