import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/common/backend_methods.dart';
import 'package:news_app/features/authentication/repository/auth_repo.dart';
import 'package:news_app/features/authentication/screens/auth_screen.dart';

import '../../../common/common_widgets.dart';
import '../../../common/enums.dart';
import '../../../common/frontend_methods.dart';
import '../../../error_screen.dart';
import '../../../widgets/snack_bar.dart';
import '../screens/select_subscription_screen.dart';

class CategoryList {
  final int id;
  final String title;

  CategoryList({
    required this.id,
    required this.title,
  });
}

final categoryListNotifierProvider =
    StateNotifierProvider<CategoryListNotifier, List<CategoryList>>(
  (ref) {
    final userPrefs = ref.watch(userPrefsProvider);
    return CategoryListNotifier(ref, userPrefs);
  },
);

class CategoryListNotifier extends StateNotifier<List<CategoryList>> {
  final StateNotifierProviderRef ref;
  final UserPreferences userPrefs;

  CategoryListNotifier(this.ref, this.userPrefs) : super([]);

  Future<List<CategoryList>> fetchCategories(
    BuildContext context,
  ) async {
    log('Fetch Categories Ran');

    String? userPassEncoded = userPrefs.getAuthData();
    String? url = userPrefs.getUrlData();

    /// TODO: Add Everywhere
    if (userPassEncoded == null || url == null) {
      navigateError(context, ErrorString.somethingWrongAuth.value);
    }

    try {
      // https://read.rusi.me/v1/categories
      Uri uri = Uri.https(url!, 'v1/categories', {});

      http.Response res = await getHttpResp(uri, userPassEncoded);

      List<dynamic> decodedData = jsonDecode(res.body);

      final List<CategoryList> fetchedCategoryList = [];

      for (var i = 0; i < decodedData.length; i++) {
        final categoryList = CategoryList(
          id: decodedData[i]['id'],
          title: decodedData[i]['title'],
        );

        fetchedCategoryList.add(categoryList);
      }
      return state = fetchedCategoryList;
    } on TimeoutException catch (_) {
      stopShowError(ref, context, ErrorString.timeout.value);
      return [];
    } on SocketException catch (_) {
      stopShowError(ref, context, ErrorString.checkInternet.value);
      return [];
    } catch (e) {
      log('CAT-LIST-FETCH: $e');
      stopShowError(ref, context, '$e');
      return [];
    }
  }
}

void stopShowError(
  StateNotifierProviderRef ref,
  BuildContext context,
  String message,
) {
  ref.read(isLoadingSubsProvider.notifier).update((state) => false);
  navigateError(context, message);
}
