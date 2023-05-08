import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettings extends Notifier<bool?> {
  static SharedPreferences? prefs;

  static Future init() async => prefs = await SharedPreferences.getInstance();

  @override
  bool? build() {
    return prefs!.getBool(keyThemeMode);
  }

  static const keyThemeMode = 'themeMode';

  Future setThemeMode(bool darkEnabled) async {
    state = darkEnabled;
    return await prefs!.setBool(keyThemeMode, darkEnabled);
  }
}

final userSettingsProvider = NotifierProvider<UserSettings, bool?>(
  UserSettings.new,
);
