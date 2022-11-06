import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:http/http.dart' as http;

import '../../../common/backend_methods.dart';
import '../../../common/common_widgets.dart';
import '../../../common/enums.dart';
import '../../../models/model.dart';
import '../../authentication/repository/auth_repo.dart';


// /// Future Provider
// final catFeedRepoFuture =
//     FutureProvider.family<List<CategoryList>, BuildContext>((ref, context) {
//   //
//   return ref.watch(catFeedRepoProvider.notifier).fetchCategoryFeeds(context);
// });

// final deleteCatFeedFuture = FutureProvider((ref) {
//   return ref.watch(catFeedRepoProvider.notifier).deleteFeed();
// });

/// State Provider
final catFeedRepoProvider =
    StateNotifierProvider<CategoryFeedRepository, List<CategoryList>>((ref) {
  final userPrefs = ref.watch(userPrefsProvider);
  final userPassEncoded = userPrefs.getAuthData();
  final baseUrl = userPrefs.getUrlData();

  // final catId = ref.watch(categoryIdProvider);

  return CategoryFeedRepository(
    ref,
    userPrefs,
    // catId,
    userPassEncoded,
    baseUrl,
  );
});

/// State Notifier
class CategoryFeedRepository extends StateNotifier<List<CategoryList>> {
  final StateNotifierProviderRef ref;
  final UserPreferences userPrefs;

  // final int categoryId;
  final String? userPassEncoded;
  final String? baseUrl;

  CategoryFeedRepository(
    this.ref,
    this.userPrefs,
    // this.categoryId,
    this.userPassEncoded,
    this.baseUrl,
  ) : super([]);

  Future<List<CategoryList>> fetchCategoryFeeds(
    BuildContext context,
    int categoryId,
  ) async {
    log('Cat Id: $categoryId');

    checkAuth(context, userPassEncoded, baseUrl, userPrefs);

    try {
      Uri uri = Uri.https(baseUrl!, 'v1/categories/$categoryId/feeds');

      final res = await getHttpResp(uri, userPassEncoded!);

      log(res.statusCode.toString());

      final List<CategoryList> list = [];

      if (res.statusCode == 200) {
        List<dynamic> decodedData = jsonDecode(res.body);

        for (var i = 0; i < decodedData.length; i++) {
          final data = CategoryList(
            id: decodedData[i]['id'],
            title: decodedData[i]['title'],
          );

          list.add(data);
        }
      } else {
        showErrorSnackBar(
          context: context,
          text: ErrorString.somethingWrongAdmin.value,
        );
      }

      return state = list;
    } on TimeoutException catch (e) {
      log('Timeout Error: $e');
      rethrow;
    } on SocketException catch (e) {
      log('Socket Error: $e');

      showSnackBar(
        context: context,
        text: 'Please check Internet Connectivity',
      );
      rethrow;
    } on Error catch (e) {
      log('General Error: $e');
      rethrow;
    } catch (e) {
      log('MAN-CAT-FETCH: $e');
      showSnackBar(context: context, text: '$e');
      // return [];
      rethrow;
    }
  }

  /// Delete
  Future<void> deleteCatFeed(
    BuildContext currentContext,
    CategoryList categoryItem,
  ) async {
    final int itemId = categoryItem.id; // Feed item id
    final String catTitle = categoryItem.title;

    final catItem = state.firstWhere((e) => e.id == itemId);
    final itemIndex = state.indexWhere((e) => e.id == itemId);

    state = [
      for (final item in state)
        if (item.id != itemId) item,
    ];

    // 'https://read.rusi.me/v1/categories/$id
    Uri uri = Uri.https(baseUrl!, 'v1/categoriesaa/$itemId');

    try {
      final res = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'authorization': userPassEncoded!,
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

  ///
  Future<void> updateCatFeed(
    BuildContext context, // currentScaffoldKey
    int id,
    String newCategoryTitle,
  ) async {
    checkAuth(context, userPassEncoded, baseUrl, userPrefs);

    try {
      final res = await putHttpResp(
          uri: null,
          url: 'https://$baseUrl/v1/categories/$id',
          userPassEncoded: userPassEncoded,
          bodyMap: {"title": newCategoryTitle});

      if (res.statusCode == 201) {
        if (!mounted) return;
        Navigator.of(context).pop();

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

// ///
// Future<List> categoryFeedDetails(
//   BuildContext context,
// ) async {
//   checkAuth(context, userPassEncoded, baseUrl, userPrefs);
//
//   try {
//     Uri uri = Uri.https(baseUrl!, 'v1/categories/$categoryId/feeds');
//
//     // http.Response res = await http.get(
//     //   uri,
//     //   headers: {
//     //     'Content-Type': 'application/json; charset=UTF-8',
//     //     // 'X-Auth-Token': '-5YfpcHn8F__jMhC0MFA-AaMrqLl5ehBaesPuvjCOzg=',
//     //     'authorization': userPassEncoded!,
//     //   },
//     // );
//
//     final res = await getHttpResp(uri, userPassEncoded!);
//
//     log(res.statusCode.toString());
//
//     List<dynamic> decodedData = jsonDecode(res.body);
//
//     final List<CategoryList> list = [];
//     //
//     for (var i = 0; i < decodedData.length; i++) {
//       log(decodedData[i]['title']);
//
//       final data = decodedData[i]['title'];
//
//       list.add(data);
//     }
//     return state = list;
//   }
//   // on SocketException catch (e) {
//   //   log('CAT-LIST-FETCH: SOCKET EXCEPTION: $e');
//   //   // Navigator.of(context).pushNamed(ErrorScreen.routeNamed);
//   //   return [];
//   // }
//   catch (e) {
//     log('MAN-CAT-FETCH: $e');
//     showSnackBar(context: context, text: '$e');
//     // return [];
//     rethrow;
//   }
// }
}
