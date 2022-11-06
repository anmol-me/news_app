import 'dart:convert';
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/features/authentication/screens/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/common_widgets.dart';
import '../../../common/constants.dart';
import '../../../common/enums.dart';
import '../../../common/backend_methods.dart';
import '../../home/screens/home_feed_screen.dart';

final authRepoProvider = Provider(
  (ref) {
    final userPrefs = ref.watch(userPrefsProvider);
    return AuthRepo(ref, userPrefs);
  },
);

class AuthRepo {
  final ProviderRef ref;
  final UserPreferences userPrefs;
  bool isAuthScreen = true;

  AuthRepo(this.ref, this.userPrefs);

  bool get isAuth {
    if (userPrefs.getAuthData() == null) {
      isAuthScreen = true;
    } else {
      isAuthScreen = false;
    }
    return isAuthScreen;
  }

  ///////////////////////////////////////////////////////////////////////////////
  Future<int?> authUrlChecker(BuildContext context) async {
    try {
      String userPassEncoded = userPrefs.getAuthData()!;

      Uri uri = Uri.https(userPrefs.getUrlData()!, 'v1/me');

      log('Stored: ${userPrefs.getUrlData()}');
      log("createdUrl: $uri");

      final res = await getHttpResp(uri, userPassEncoded);

      log('${res.statusCode}');
      return res.statusCode;
    } catch (e) {
      log('Checker E: $e');
      return null;
    }
  }

/////////////////////////////////////////////////////////////////////////////////

  Future<void> login({
    required GlobalKey<FormState> formKey,
    required BuildContext context,
    required WidgetRef ref,
    required TextEditingController usernameController,
    required TextEditingController passwordController,
    required TextEditingController urlController,
    required Mode mode,
  }) async {
    final isLoadingLoginController = ref.read(isLoadingLoginProvider.notifier);
    isLoadingLoginController.update((state) => true);

    final isValid = formKey.currentState!.validate();

    if (isValid) {
      final navigator = Navigator.of(context);
      String userPassEncoded;

      // final authRepoController = ref.read(authRepoProvider);
      final userPrefs = ref.read(userPrefsProvider);

      final bool isTestUser = usernameController.text == demoUser &&
          passwordController.text == demoPassword &&
          mode == Mode.basic;

      if (isTestUser) {
        // Test Mode
        userPrefs.setUrlData(staticUrl);
        log('Test url: ${userPrefs.getUrlData()}');

        userPassEncoded = 'Basic ${base64.encode(
          utf8.encode(
            '$staticUsername:$staticPassword',
          ),
        )}';
      } else {
        // Basic Mode
        if (mode == Mode.basic) {
          userPrefs.setUrlData(defaultUrl);
          log('Basic login Default url has been set: ${userPrefs.getUrlData()}');
        } else {
          // Advanced Mode
          userPrefs.setUrlData(urlController.text);
          log('Advanced login Custom url has been set: ${userPrefs.getUrlData()}');
        }

        userPassEncoded = 'Basic ${base64.encode(
          utf8.encode(
            '${usernameController.text}:${passwordController.text}',
          ),
        )}';
      }

      userPrefs.setAuthData(userPassEncoded);

      if (userPrefs.getAuthData() == null || userPrefs.getUrlData() == null) {
        showSnackBar(context: context, text: ErrorString.internalError.value);
        userPrefs.clearPrefs();
        return;
      }

      final statusCode = await authUrlChecker(context);

      if (statusCode == 200) {
        navigator.pushNamed(HomeFeedScreen.routeNamed);
      } else if (statusCode == 401) {
        showSnackBar(context: context, text: ErrorString.accessDenied.value);
        userPrefs.clearPrefs();
      } else {
        showSnackBar(context: context, text: ErrorString.somethingWrongAdmin.value);
        userPrefs.clearPrefs();
      }
    } // isValid
    isLoadingLoginController.update((state) => false);
  }

  void logout(BuildContext context) async {
    userPrefs.clearPrefs();
    Navigator.of(context).pushNamed(AuthScreen.routeNamed);
  }
}

/// ---------------------------------------------------------------------------

final userPrefsProvider = Provider((ref) => UserPreferences());

class UserPreferences {
  static SharedPreferences? prefs;

  static const keyAuthData = 'authData';
  static const keyUrlData = 'urlData';

  static Future init() async => prefs = await SharedPreferences.getInstance();

  Future setAuthData(String authData) async {
    return await prefs!.setString(keyAuthData, authData);
  }

  String? getAuthData() => prefs!.getString(keyAuthData);

  Future setUrlData(String urlData) async {
    return await prefs!.setString(keyUrlData, urlData);
  }

  String? getUrlData() => prefs!.getString(keyUrlData);

  void clearPrefs() => prefs?.clear();
}

// /// Provider & Class ------------------------------------------------------------------------
// final authMethodsProvider = Provider((ref) {
//   final prefsUrl = ref.watch(userPrefsProvider).getUrlData();
//   final userPassEncoded = ref.watch(userPrefsProvider).getAuthData();
//
//   return AuthMethods(prefsUrl: prefsUrl!, userPassEncoded: userPassEncoded!);
// });
//
// class AuthMethods {
//   final String prefsUrl;
//   final String userPassEncoded;
//
//   AuthMethods({
//     required this.prefsUrl,
//     required this.userPassEncoded,
//   });
//
//   Future<int?> authUrlChecker(BuildContext context) async {
//     try {
//       Uri uri = Uri.https(prefsUrl, 'v1/me');
//
//       log('Stored: $prefsUrl');
//       log("createdUrl: $uri");
//       // log("authData: $authData");
//
//       final res = await getHttpResp(uri, userPassEncoded);
//
//       log('${res.statusCode}');
//       return res.statusCode;
//     } catch (e) {
//       log('Checker E: $e');
//       return null;
//     }
//   }
// }
