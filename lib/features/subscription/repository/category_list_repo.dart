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
import '../screens/select_subscription_screen/select_subscription_screen.dart';

final isDeletingCatProvider = StateProvider((ref) => false);

final categoryListNotifierProvider =
    StateNotifierProvider<CategoryListNotifier, List<CategoryList>>(
  (ref) {
    final userPrefs = ref.watch(userPrefsProvider);
    String? userPassEncoded = userPrefs.getAuthData();
    String? baseUrl = userPrefs.getUrlData();

    return CategoryListNotifier(
      ref,
      userPrefs,
      userPassEncoded!,
      baseUrl!,
    );
  },
);

class CategoryListNotifier extends StateNotifier<List<CategoryList>> {
  final StateNotifierProviderRef ref;
  final UserPreferences userPrefs;
  final String userPassEncoded;
  final String baseUrl;

  CategoryListNotifier(
    this.ref,
    this.userPrefs,
    this.userPassEncoded,
    this.baseUrl,
  ) : super([]);

  /// Fetch Categories
  Future<List<CategoryList>> fetchCategories(
    BuildContext context,
  ) async {
    log('Fetch Categories Ran');

    try {
      // https://read.rusi.me/v1/categories
      Uri uri = Uri.https(baseUrl, 'v1/categories', {});

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
    final themeCxt = Theme.of(context);

    try {
      final res = await postHttpResp(
        uri: null,
        userPassEncoded: userPassEncoded,
        url: Uri.parse('https://$baseUrl/v1/categories'),
        bodyMap: {"title": categoryTitle},
      );

      log('${res.statusCode}');

      // Map decodedData = jsonDecode(res.body);

      if (res.statusCode == 400) {
        if (mounted) Navigator.of(context).pop();

        scaffoldMessenger.showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 10),
            backgroundColor: themeCxt.colorScheme.error,
            content: Text(ErrorString.catAlreadyExists.value),
          ),
        );
        return;
      }

      final decodedData = jsonDecode(res.body);

      final categoryListItem = CategoryList(
        id: decodedData['id'],
        title: decodedData['title'],
      );

      if (mounted) {
        Navigator.of(context).pop();
        showSnackBar(context: context, text: ErrorString.catCreated.value);
      }

      state = [...state, categoryListItem];
      state.map((e) => log(e.title)).toList().toString();
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
    BuildContext listContext,
    int catId,
    String catTitle,
  ) async {
    final catItem = state.firstWhere((e) => e.id == catId);
    final itemIndex = state.indexWhere((e) => e.id == catId);

    state = [
      for (final item in state)
        if (item.id != catId) item,
    ];

    // 'https://read.rusi.me/v1/categories/$id
    Uri uri = Uri.https(baseUrl, 'v1/categories/$catId');

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
          context: listContext,
          text: 'Successfully deleted $catTitle',
        );
      } else {
        state = [...state]..insert(itemIndex, catItem);

        showErrorSnackBar(
          context: listContext,
          text: ErrorString.catNotDelete.value,
        );
      }
    } on TimeoutException catch (_) {
      state = [...state]..insert(itemIndex, catItem);
      // state = [...state].insert(itemIndex, catItem);

      showErrorSnackBar(
          context: listContext,
          text:
              '${ErrorString.catNotDelete.value} ${ErrorString.timeout.value}');
    } on SocketException catch (_) {
      state = [...state]..insert(itemIndex, catItem);

      showErrorSnackBar(
        context: listContext,
        text:
            '${ErrorString.catNotDelete.value} ${ErrorString.checkInternet.value}',
      );
    } catch (e) {
      state = [...state]..insert(itemIndex, catItem);

      showErrorSnackBar(context: listContext, text: '$e');
    }
  }

  Future<void> updateCategoryName(
    BuildContext context,
    int id,
    String newCategoryTitle,
  ) async {
    checkAuth(context, userPassEncoded, baseUrl, userPrefs);
    final navigator = Navigator.of(context);

    try {
      final res = await putHttpResp(
          uri: null,
          url: 'https://$baseUrl/v1/categories/$id',
          userPassEncoded: userPassEncoded,
          bodyMap: {"title": newCategoryTitle});

      if (res.statusCode == 201) {
        navigator.pop();

        state = [
          for (final item in state)
            if (item.id == id) item.copyWith(title: newCategoryTitle) else item,
        ];

        showSnackBar(
          context: context,
          text: 'Name changed to $newCategoryTitle',
        );
      } else {
        showErrorSnackBar(
          context: context,
          text: 'Name change unsuccessful',
        );
      }
      log('UPDATE-SUBS-C: ${res.statusCode}');
    } on TimeoutException catch (e) {
      log('Timeout Error: $e');
    } on SocketException catch (e) {
      log('Socket Error: $e');

      showSnackBar(
        context: context,
        text: 'Please check Internet Connectivity',
      );
    } on Error catch (e) {
      log('General Error: $e');
    } catch (e) {
      log('UPDATE-SUBS: $e');
      showSnackBar(context: context, text: '$e');
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
