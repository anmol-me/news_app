import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

import 'package:news_app/features/authentication/screens/auth_screen.dart';
import '../../../common/common_widgets.dart';
import '../../../common/constants.dart';
import '../../../common/enums.dart';
import '../../../common/backend_methods.dart';
import '../../../responsive/responsive_app.dart';
import '../../home/screens/home_feed_screen.dart';
import '../../home/screens/home_web_screen.dart';

final authRepoProvider = Provider(
  (ref) {
    final userPrefs = ref.watch(userPrefsProvider);
    return AuthRepo(ref, userPrefs);
  },
);

class AuthRepo {
  final ProviderRef ref;
  final UserPreferences userPrefs;
  bool isAuth = false;

  AuthRepo(this.ref, this.userPrefs);

  bool get isAuthenticated {
    if (userPrefs.getAuthData() == null) {
      isAuth = false;
    } else {
      isAuth = true;
    }
    return isAuth;
  }

  ///////////////////////////////////////////////////////////////////////////////
  Future<int?> authUrlChecker(BuildContext context) async {
    try {
      String userPassEncoded = userPrefs.getAuthData()!;

      Uri uri = Uri.https(userPrefs.getUrlData()!, 'v1/me');

      log("Prefs -> uri created: $uri");

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
      // final navigator = Navigator.of(context);
      String userPassEncoded;

      // final authRepoController = ref.read(authRepoProvider);
      final userPrefs = ref.read(userPrefsProvider);

      final bool isTestUser = usernameController.text == demoUser &&
          passwordController.text == demoPassword &&
          mode == Mode.basic;

      if (isTestUser) {
        // Test Mode
        userPrefs.setUrlData(staticUrl);
        // log('Login prefs test url : ${userPrefs.getUrlData()}');

        userPassEncoded = 'Basic ${base64.encode(utf8.encode(
          '$staticUsername:$staticPassword',
        ))}';
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
      log('Login Prefs auth: ${userPrefs.getAuthData()}');

      final userData = userPrefs.getAuthData();
      final urlData = userPrefs.getUrlData();

      if (userData == null ||
          userData.isEmpty ||
          urlData == null ||
          urlData.isEmpty) {
        showErrorSnackBar(
            context: context, text: ErrorString.internalError.value);
        userPrefs.clearPrefs();
        return;
      }

      final statusCode = await authUrlChecker(context);

      log('Login Status: $statusCode');

      if (statusCode == 200) {
        // navigator.pushNamed(HomeFeedScreen.routeNamed);
        if (context.mounted) {
          context.goNamed(HomeFeedScreen.routeNamed);
        }
      } else if (statusCode == 401) {
        if (context.mounted) {
          showSnackBar(context: context, text: ErrorString.accessDenied.value);
        }
        userPrefs.clearPrefs();
      } else {
        if (context.mounted) {
          showSnackBar(
              context: context, text: ErrorString.somethingWrongAdmin.value);
        }
        userPrefs.clearPrefs();
      }
    } // isValid
    isLoadingLoginController.update((state) => false);
  }

  void logout(BuildContext context) async {
    userPrefs.clearPrefs();
    // Navigator.of(context).pushNamed(AuthScreen.routeNamed);
    context.goNamed(AuthScreen.routeNamed);
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
