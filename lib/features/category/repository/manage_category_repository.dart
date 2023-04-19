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

/// Notifier Provider
final manageCateNotifierProvider =
    NotifierProvider<ManageCategoryRepository, List<CategoryList>>(
        ManageCategoryRepository.new);

/// Notifier
class ManageCategoryRepository extends Notifier<List<CategoryList>> {
  late UserPreferences userPrefs;

  // late int categoryId;
  late String? userPassEncoded;
  late String? baseUrl;

  @override
  List<CategoryList> build() {
    // catId = ref.watch(categoryIdProvider);
    userPrefs = ref.watch(userPrefsProvider);
    userPassEncoded = userPrefs.getAuthData();
    baseUrl = userPrefs.getUrlData();
    return [];
  }

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
        if (context.mounted) {
          showErrorSnackBar(
            context: context,
            text: ErrorString.somethingWrongAdmin.value,
          );
        }
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
    BuildContext context,
    CategoryList categoryItem,
  ) async {
    final int itemId = categoryItem.id;
    final String catTitle = categoryItem.title;

    final catItem = state.firstWhere((e) => e.id == itemId);
    final itemIndex = state.indexWhere((e) => e.id == itemId);

    state = [
      for (final item in state)
        if (item.id != itemId) item,
    ];

    // 'https://read.rusi.me/v1/categories/$id
    Uri uri = Uri.https(baseUrl!, 'v1/feeds/$itemId');

    try {
      final res = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'authorization': userPassEncoded!,
        },
      );

      if (res.statusCode == 204) {
        if (context.mounted) {
          showSnackBar(
            context: context,
            text: 'Successfully deleted $catTitle',
          );
        }
      } else {
        state = [...state]..insert(itemIndex, catItem);

        if (context.mounted) {
          showErrorSnackBar(
            context: context,
            text: ErrorString.catNotDelete.value,
          );
        }
      }
    } on TimeoutException catch (_) {
      state = [...state]..insert(itemIndex, catItem);
      // state = [...state].insert(itemIndex, catItem);

      showErrorSnackBar(
          context: context,
          text:
              '${ErrorString.catNotDelete.value} ${ErrorString.requestTimeout.value}');
    } on SocketException catch (_) {
      state = [...state]..insert(itemIndex, catItem);

      showErrorSnackBar(
        context: context,
        text:
            '${ErrorString.catNotDelete.value} ${ErrorString.checkInternet.value}',
      );
    } catch (e) {
      state = [...state]..insert(itemIndex, catItem);

      showErrorSnackBar(context: context, text: '$e');
    }
  }

  Future<void> updateCatFeedName({
    required BuildContext listContext,
    required int feedId,
    required int catId,
    required String newFeedTitle,
  }) async {
    checkAuth(listContext, userPassEncoded, baseUrl, userPrefs);
    final navigator = Navigator.of(listContext);

    try {
      final res = await putHttpResp(
          uri: null,
          url: 'https://$baseUrl/v1/feeds/$feedId',
          userPassEncoded: userPassEncoded,
          bodyMap: {
            "title": newFeedTitle,
            "category_id": catId,
          });

      if (res.statusCode == 201) {
        navigator.pop();

        state = [
          for (final item in state)
            if (item.id == feedId) item.copyWith(title: newFeedTitle) else item,
        ];

        if (listContext.mounted) {
          showSnackBar(
            context: listContext,
            text: 'Name changed to $newFeedTitle',
          );
        }
      } else {
        if (listContext.mounted) {
          showErrorSnackBar(
            context: listContext,
            text: 'Name change unsuccessful',
          );
        }
      }
      log('UPDATE-SUBS-C: ${res.statusCode}');
    } on TimeoutException catch (e) {
      log('Timeout Error: $e');
    } on SocketException catch (e) {
      log('Socket Error: $e');

      showSnackBar(
        context: listContext,
        text: 'Please check Internet Connectivity',
      );
    } on Error catch (e) {
      log('General Error: $e');
    } catch (e) {
      log('UPDATE-SUBS: $e');
      showSnackBar(context: listContext, text: '$e');
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
