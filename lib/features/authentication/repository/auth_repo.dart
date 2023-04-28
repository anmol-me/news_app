import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/common/common_methods.dart';
import 'package:news_app/features/authentication/repository/user_preferences.dart';

import 'package:news_app/features/authentication/screens/auth_screen.dart';
import '../../../common_widgets/common_widgets.dart';
import '../../../common/constants.dart';
import '../../../common/enums.dart';
import '../../../common/api_methods.dart';
import '../../home/screens/home_feed_screen.dart';

final authRepoProvider = Provider(
  (ref) {
    final userPrefs = ref.watch(userPrefsProvider);
    return AuthRepo(ref, userPrefs);
  },
);

class AuthRepo {
  final Ref ref;
  final UserPreferences userPrefs;
  bool isAuth = false;

  AuthRepo(this.ref, this.userPrefs);

  bool get isAuthenticated {
    print('Authenticated: ${userPrefs.getIsAuth()}');
    return isAuth = userPrefs.getIsAuth()!;
  }

  Future<int?> authUrlChecker(String userPassEncoded, String urlData) async {
    try {
      Uri uri = Uri.https(urlData, 'v1/me');

      log("Prefs -> uri created: $uri");

      final res = await getHttpResp(uri, userPassEncoded);

      log('${res.statusCode}');
      return res.statusCode;
    } catch (e) {
      log('Checker E: $e');
      return null;
    }
  }

  Future<void> login({
    required GlobalKey<FormState> formKey,
    required BuildContext context,
    required TextEditingController usernameController,
    required TextEditingController passwordController,
    required TextEditingController urlController,
  }) async {
    final isLoadingLoginController = ref.read(isLoadingLoginProvider.notifier);
    isLoadingLoginController.update((state) => true);

    final isValid = formKey.currentState!.validate();

    final mode = ref.read(modeProvider);

    if (isValid) {
      String userPassEncoded;

      final bool isTestUser = usernameController.text == demoUser &&
          passwordController.text == demoPassword &&
          mode == Mode.basic;

      if (isTestUser) {
        // Test Mode
        await userPrefs.setUrlData(staticUrl);
        // log('Login prefs test url : ${userPrefs.getUrlData()}');

        userPassEncoded = 'Basic ${base64.encode(utf8.encode(
          '$staticUsername:$staticPassword',
        ))}';
      } else {
        // Basic Mode
        if (mode == Mode.basic) {
          await userPrefs.setUrlData(defaultUrl);
          log('Basic login Default url has been set: ${userPrefs.getUrlData()}');
        } else {
          // Advanced Mode
          await userPrefs.setUrlData(urlController.text);
          log('Advanced login Custom url has been set: ${userPrefs.getUrlData()}');
        }

        userPassEncoded = 'Basic ${base64.encode(
          utf8.encode(
            '${usernameController.text}:${passwordController.text}',
          ),
        )}';
      }

      final isAuthSet = await userPrefs.setAuthData(userPassEncoded);

      log('Login Prefs auth: ${userPrefs.getAuthData()}');

      final authData = userPrefs.getAuthData();
      final urlData = userPrefs.getUrlData();

      if (authData == null ||
          authData.isEmpty ||
          urlData == null ||
          urlData.isEmpty ||
          !isAuthSet) {
        if (context.mounted) {
          showErrorSnackBar(
            context: context,
            text: ErrorString.internalError.value,
          );
        }
        userPrefs.clearPrefs();
        return;
      }

      final statusCode = await authUrlChecker(authData, urlData);

      log('Login Status: $statusCode');

      if (statusCode == 200) {
        userPrefs.setIsAuth(true);

        if (context.mounted) {
          context.goNamed(HomeFeedScreen.routeNamed);
        }
      } else if (statusCode == 401) {
        if (context.mounted) {
          showErrorSnackBar(
            context: context,
            text: ErrorString.accessDenied.value,
          );
        }
        userPrefs.clearPrefs();
      } else {
        if (context.mounted) {
          showErrorSnackBar(
            context: context,
            text: ErrorString.somethingWrongAdmin.value,
          );
        }
        userPrefs.clearPrefs();
      }
    } // isValid
    isLoadingLoginController.update((state) => false);
  }

  void logout(BuildContext context) async {
    userPrefs.clearPrefs();
    userPrefs.setIsAuth(false);

    if (ref.read(isHomeDrawerOpened)) {
      if (context.mounted) Navigator.of(context).pop();
    }

    context.goNamed(AuthScreen.routeNamed);
  }
}
