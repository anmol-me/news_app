import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/common/common_methods.dart';
import 'package:news_app/features/authentication/repository/user_preferences.dart';

import 'package:news_app/features/authentication/screens/auth_screen.dart';
import '../../../common/error.dart';
import '../../../common_widgets/common_widgets.dart';
import '../../../common/constants.dart';
import '../../../common/enums.dart';
import '../../../common/api_methods.dart';
import '../../app_bar/user_repository.dart';
import '../../category/repository/category_repo.dart';
import '../../category/repository/manage_category_repository.dart';
import '../../home/providers/home_providers.dart';
import '../../home/screens/home_feed_screen.dart';
import '../../settings/repository/settings_repository.dart';
import '../../subscription/repository/subscription_repository.dart';

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

  Future authUrlChecker(String userPassEncoded, String urlData) async {
    Uri uri = Uri.https(urlData, 'v1/me');
    final res = await getHttpResp(uri, userPassEncoded);
    return res;
  }

  Future<void> login({
    required GlobalKey<FormState> formKey,
    required BuildContext context,
    required TextEditingController usernameController,
    required TextEditingController passwordController,
    required TextEditingController urlController,
  }) async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    final isLoadingLoginController = ref.read(isLoadingLoginProvider.notifier);
    isLoadingLoginController.update((state) => true);

    final mode = ref.read(modeProvider);

    try {
      String userPassEncoded;

      final bool isTestUser = usernameController.text == demoUser &&
          passwordController.text == demoPassword &&
          mode == Mode.basic;

      if (isTestUser) {
        // Test Mode
        await userPrefs.setUrlData(staticUrl);
        log('Login prefs test url : ${userPrefs.getUrlData()}');

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

      if (!isAuthSet ||
          authData == null ||
          authData.isEmpty ||
          urlData == null ||
          urlData.isEmpty) {
        if (context.mounted) {
          showErrorSnackBar(
            context: context,
            text: ErrorString.internalError.value,
          );
        }
        isLoadingLoginController.update((state) => false);
        userPrefs.clearPrefs();
        return;
      }

      final res = await authUrlChecker(authData, urlData);

      log('Login Status: ${res.statusCode}');

      if (res.statusCode >= 400 && res.statusCode <= 599) {
        isLoadingLoginController.update((state) => false);
        throw ServerErrorException(res);
      }

      if (res.statusCode == 200) {
        userPrefs.setIsAuth(true);

        if (context.mounted) {
          context.goNamed(HomeFeedScreen.routeNamed);
        }
      }
      isLoadingLoginController.update((state) => false);
    } on SocketException catch (_) {
      isLoadingLoginController.update((state) => false);
      userPrefs.clearPrefs();
      showErrorSnackBar(
          context: context, text: ErrorString.checkInternet.value);
    } on TimeoutException catch (_) {
      isLoadingLoginController.update((state) => false);
      userPrefs.clearPrefs();
      showErrorSnackBar(
          context: context, text: ErrorString.requestTimeout.value);
    } on ServerErrorException catch (e) {
      isLoadingLoginController.update((state) => false);
      userPrefs.clearPrefs();
      showErrorSnackBar(context: context, text: '$e');
    } catch (e) {
      isLoadingLoginController.update((state) => false);
      userPrefs.clearPrefs();
      showErrorSnackBar(context: context, text: ErrorString.generalError.value);
    }
  }

  void logout(BuildContext context) async {
    userPrefs.clearPrefs();

    ref.invalidate(userNotifierProvider);
    ref.invalidate(homePageLoadingProvider);
    ref.invalidate(homeFeedProvider);
    ref.invalidate(subscriptionNotifierProvider);
    ref.invalidate(categoryNotifierProvider);
    ref.invalidate(manageCateNotifierProvider);
    ref.invalidate(userSettingsProvider);
    ref.invalidate(authRepoProvider);
    ref.invalidate(isStarredProvider);

    if (ref.read(isHomeDrawerOpened)) {
      if (context.mounted) Navigator.of(context).pop();
    }

    context.goNamed(AuthScreen.routeNamed);
  }
}
