import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/common/backend_methods.dart';
import 'package:news_app/features/authentication/repository/auth_repo.dart';

import '../../../common/common_widgets.dart';
import '../../../common/enums.dart';
import '../../../common/frontend_methods.dart';
import '../../../common/error_screen.dart';
import '../../../models/model.dart';
import '../screens/select_subscription_screen.dart';

final isDeletingCatProvider = StateProvider((ref) => false);

final categoryListNotifierProvider =
    StateNotifierProvider<CategoryListNotifier, List<CategoryList>>(
  (ref) {
    final userPrefs = ref.watch(userPrefsProvider);
    String? userPassEncoded = userPrefs.getAuthData();
    String? url = userPrefs.getUrlData();

    return CategoryListNotifier(
      ref,
      userPrefs,
      userPassEncoded!,
      url!,
    );
  },
);

class CategoryListNotifier extends StateNotifier<List<CategoryList>> {
  final StateNotifierProviderRef ref;
  final UserPreferences userPrefs;
  final String userPassEncoded;
  final String url;

  CategoryListNotifier(
    this.ref,
    this.userPrefs,
    this.userPassEncoded,
    this.url,
  ) : super([]);

  /// Fetch Categories
  Future<List<CategoryList>> fetchCategories(
    BuildContext context,
  ) async {
    log('Fetch Categories Ran');

    /// TODO: Add Everywhere
    if (userPassEncoded.isEmpty || url.isEmpty) {
      navigateError(context, ErrorString.somethingWrongAuth.value);
    }

    try {
      // https://read.rusi.me/v1/categories
      Uri uri = Uri.https(url, 'v1/categories', {});

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

  /// Create Category
  Future<void> createCategory(
    String categoryTitle,
    BuildContext context,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final themeCxt = Theme.of(context);

    try {
      final res = await postHttpResp(
        uri: null,
        userPassEncoded: userPassEncoded,
        url: Uri.parse('https://$url/v1/categories'),
        bodyMap: {"title": categoryTitle},
      );

      log('${res.statusCode}');

      // Map decodedData = jsonDecode(res.body);

      if (res.statusCode == 400) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 10),
            backgroundColor: themeCxt.errorColor,
            content: Text(ErrorString.catAlreadyExists.value),
          ),
        );
      }

      final decodedData = jsonDecode(res.body);

      final categoryListItem = CategoryList(
        id: decodedData['id'],
        title: decodedData['title'],
      );

      showSnackBar(context: context, text: ErrorString.catCreated.value);
      navigator.pop();
      state = [...state, categoryListItem];
      log(state.toList().toString());
    } on TimeoutException catch (e) {
      log('Timeout Error: $e');
    } on SocketException catch (e) {
      log('Socket Error: $e');

      showSnackBar(
        context: context,
        text: 'Please check Internet Connectivity',
      );
    } catch (e) {
      log('UPDATE-SUBS: $e');
      showSnackBar(context: context, text: '$e');
    }
  }

  /// Delete
  Future<void> deleteCategory(
    BuildContext currentContext,
    int catId,
    String catTitle,
  ) async {
    final catItem = state.firstWhere((e) => e.id == catId);
    final itemIndex = state.indexWhere((e) => e.id == catId);

    state = [
      for (final item in state)
        if (item.id != catId) item,
    ];

    Navigator.of(currentContext).pop();

    // 'https://read.rusi.me/v1/categories/$id
    Uri uri = Uri.https(url, 'v1/categoriesaa/$catId');

    try {
      final res = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'authorization': userPassEncoded,
        },
      );

      if (res.statusCode == 204) {
        showSnackBar(
          context: currentContext,
          text: 'Successfully deleted $catTitle',
        );
      } else {
        state = [...state]..insert(itemIndex, catItem);

        showErrorSnackBar(
          context: currentContext,
          text: ErrorString.catNotDelete.value,
        );
      }
    } on TimeoutException catch (_) {
      state = [...state]..insert(itemIndex, catItem);
      // state = [...state].insert(itemIndex, catItem);

      showErrorSnackBar(
          context: currentContext,
          text:
              '${ErrorString.catNotDelete.value} ${ErrorString.timeout.value}');
    } on SocketException catch (_) {
      state = [...state]..insert(itemIndex, catItem);

      showErrorSnackBar(
        context: currentContext,
        text:
            '${ErrorString.catNotDelete.value} ${ErrorString.checkInternet.value}',
      );
    } catch (e) {
      state = [...state]..insert(itemIndex, catItem);

      showErrorSnackBar(context: currentContext, text: '$e');
    }
  }

//
}

void stopShowError(
  StateNotifierProviderRef ref,
  BuildContext context,
  String message,
) {
  ref.read(isLoadingSubsProvider.notifier).update((state) => false);
  navigateError(context, message);
}
