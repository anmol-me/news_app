import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/common/common_methods.dart';
import 'package:news_app/common/common_providers.dart';
import 'package:news_app/features/authentication/repository/user_preferences.dart';

import 'package:news_app/features/authentication/screens/auth_screen.dart';
import 'package:news_app/features/category/screens/edit_feed_screen.dart';
import 'package:news_app/features/details/components/providers.dart';
import 'package:news_app/features/subscription/screens/add_subscription_screen.dart';
import 'package:news_app/themes.dart';
import '../../../common/error.dart';
import '../../../common_widgets/common_widgets.dart';
import '../../../common/constants.dart';
import '../../../common/enums.dart';
import '../../../common/api_methods.dart';
import '../../app_bar/app_bar_repo.dart';
import '../../app_bar/user_repository.dart';
import '../../category/repository/category_repo.dart';
import '../../category/repository/manage_category_repository.dart';
import '../../category/screens/category_screen.dart';
import '../../category/screens/manage_category_screen.dart';
import '../../home/providers/home_providers.dart';
import '../../home/repository/home_methods.dart';
import '../../home/screens/home_feed_screen.dart';
import '../../search/repository/search_repo.dart';
import '../../search/screens/search_screen.dart';
import '../../settings/repository/settings_repository.dart';
import '../../settings/screens/settings_screen.dart';
import '../../subscription/repository/discovery_repository.dart';
import '../../subscription/repository/subscription_repository.dart';
import '../../subscription/screens/edit_subscription_screen.dart';

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

  bool get isAuthenticated => isAuth = userPrefs.getIsAuth()!;

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

        userPassEncoded = 'Basic ${base64.encode(utf8.encode(
          '$staticUsername:$staticPassword',
        ))}';
      } else {
        // Basic Mode
        if (mode == Mode.basic) {
          await userPrefs.setUrlData(defaultUrl);
        } else {
          // Advanced Mode
          String? url;
          if (urlController.text.startsWith('http://')) {
            isLoadingLoginController.update((state) => false);
            showErrorSnackBar(
                context: context,
                text: 'Unsecure http link is not supported in the app');
            return;
          } else if (urlController.text.startsWith('https://')) {
            url = urlController.text.replaceFirst('https://', '');
          } else {
            url = urlController.text;
          }
          await userPrefs.setUrlData(url!);
        }

        userPassEncoded = 'Basic ${base64.encode(
          utf8.encode(
            '${usernameController.text}:${passwordController.text}',
          ),
        )}';
      }

      final isAuthSet = await userPrefs.setAuthData(userPassEncoded);

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

      usernameController.clear();
      passwordController.clear();
      urlController.clear();
    } on SocketException catch (e) {
      isLoadingLoginController.update((state) => false);
      userPrefs.clearPrefs();
      showErrorSnackBar(
          context: context, text: e.message);
    } on TimeoutException catch (_) {
      isLoadingLoginController.update((state) => false);
      userPrefs.clearPrefs();
      showErrorSnackBar(
          context: context, text: ErrorString.requestTimeout.value);
    } on FormatException catch (_) {
      isLoadingLoginController.update((state) => false);
      userPrefs.clearPrefs();
      showErrorSnackBar(context: context, text: ErrorString.validUrl.value);
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
    ref.invalidate(emptyStateDisableProvider);
    ref.invalidate(disableFilterProvider);
    ref.invalidate(userPrefsProvider);
    ref.invalidate(modeProvider);
    ref.invalidate(themeModeProvider);
    ref.invalidate(appBarRepoProvider);
    ref.invalidate(catPageHandlerProvider);
    ref.invalidate(catMaxPagesProvider);
    ref.invalidate(catIsNextProvider);
    ref.invalidate(isRefreshAllLoadingProvider);

    ref.invalidate(refreshProvider);

    ref.invalidate(homeFeedProvider);
    ref.invalidate(homeMethodsProvider);
    ref.invalidate(homePageLoadingProvider);
    ref.invalidate(homeOffsetProvider);
    ref.invalidate(homeSortDirectionProvider);
    ref.invalidate(homeIsShowReadProvider);
    ref.invalidate(homeIsLoadingBookmarkProvider);

    ref.invalidate(newsDetailsProvider);
    ref.invalidate(discoveryProvider);
    ref.invalidate(selectedCategoryProvider);
    ref.invalidate(showAsteriskProvider);

    ref.invalidate(searchNotifierProvider);
    ref.invalidate(showNoResultsProvider);
    ref.invalidate(showSearchLoaderProvider);
    ref.invalidate(showFirstSearchProvider);

    ref.invalidate(subscriptionNotifierProvider);

    ref.invalidate(categoryNotifierProvider);
    ref.invalidate(catSortProvider);
    ref.invalidate(catOffsetProvider);
    ref.invalidate(manageCateNotifierProvider);

    ref.invalidate(userSettingsProvider);
    ref.invalidate(authRepoProvider);

    ref.invalidate(isStarredProvider);
    ref.invalidate(isDiscoverLoadingProvider);
    ref.invalidate(isLoadingLoginProvider);
    ref.invalidate(isCatLoadingProvider);
    ref.invalidate(isDeletingCatProvider);
    ref.invalidate(isFeedLoadingProvider);
    ref.invalidate(isFabButtonProvider);
    ref.invalidate(isTitleUpdatingProvider);
    ref.invalidate(isFeedTitleUpdatingProvider);
    ref.invalidate(isManageLoadingProvider);
    ref.invalidate(isManageProcessingProvider);

    if (ref.read(isDrawerOpenProvider)) {
      if (context.mounted) Navigator.of(context).pop();
    }

    context.goNamed(AuthScreen.routeNamed);
  }
}
