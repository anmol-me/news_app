import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../common/common_widgets.dart';
import '../../../widgets/snack_bar.dart';
import '../../authentication/repository/auth_repo.dart';
import '../../authentication/screens/auth_screen.dart';
import '../screens/manage_categories_screen.dart';

/// Model
class CategoryFeedDetails {
  final int id;
  final String title;

  CategoryFeedDetails({
    required this.id,
    required this.title,
  });
}

/// Future Provider
final manageCategoriesRepoFuture =
    FutureProvider.family<List<CategoryFeedDetails>, BuildContext>(
        (ref, context) {
  // final feedId = ref.watch(categoryFeedIdProvider);

  return ref.read(manageCategoriesRepoProvider.notifier).fetchCategoryFeeds(
        context,
        // feedId,
      );
});

/// State Provider
final manageCategoriesRepoProvider = StateNotifierProvider<
    ManageCategoriesRepository, List<CategoryFeedDetails>>((ref) {
  final userPrefs = ref.watch(userPrefsProvider);
  final feedId = ref.watch(categoryIdProvider);

  return ManageCategoriesRepository(userPrefs, feedId);
});

/// State Notifier
class ManageCategoriesRepository
    extends StateNotifier<List<CategoryFeedDetails>> {
  final UserPreferences userPrefs;
  final int categoryId;

  ManageCategoriesRepository(
    this.userPrefs,
    this.categoryId,
  ) : super([]);

  Future<List<CategoryFeedDetails>> fetchCategoryFeeds(
    BuildContext context,
    // int feedId,
  ) async {
    log(categoryId.toString());
    String? basicAuth = userPrefs.getAuthData();

    if (basicAuth == null) {
      Navigator.of(context).pushNamed(AuthScreen.routeNamed);

      showSnackBar(
        context: context,
        text: 'Something went wrong! Please login again',
      );
    }

    try {
      // Online

      Uri uri =
          Uri.https('read.rusi.me', 'v1/categories/$categoryId/feeds', {});

      http.Response res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          // 'X-Auth-Token': '-5YfpcHn8F__jMhC0MFA-AaMrqLl5ehBaesPuvjCOzg=',
          'authorization': basicAuth!,
        },
      );

      log(res.statusCode.toString());

      List<dynamic> decodedData = jsonDecode(res.body);

      final List<CategoryFeedDetails> list = [];
      //
      for (var i = 0; i < decodedData.length; i++) {
        // log(decodedData[i]['title']);

        // final data = decodedData[i]['title'];

        final data = CategoryFeedDetails(
          id: decodedData[i]['id'],
          title: decodedData[i]['title'],
        );

        list.add(data);
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

  ///
  Future<List> categoryFeedDetails(
    BuildContext context,
  ) async {
    String? basicAuth = userPrefs.getAuthData();

    if (basicAuth == null) {
      Navigator.of(context).pushNamed(AuthScreen.routeNamed);

      showSnackBar(
        context: context,
        text: 'Something went wrong! Please login again',
      );
    }

    try {
      // Online

      Uri uri =
          Uri.https('read.rusi.me', 'v1/categories/$categoryId/feeds', {});

      http.Response res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          // 'X-Auth-Token': '-5YfpcHn8F__jMhC0MFA-AaMrqLl5ehBaesPuvjCOzg=',
          'authorization': basicAuth!,
        },
      );

      log(res.statusCode.toString());

      List<dynamic> decodedData = jsonDecode(res.body);

      final List<CategoryFeedDetails> list = [];
      //
      for (var i = 0; i < decodedData.length; i++) {
        log(decodedData[i]['title']);

        final data = decodedData[i]['title'];

        list.add(data);
      }
      return state = list;
    }
    // on SocketException catch (e) {
    //   log('CAT-LIST-FETCH: SOCKET EXCEPTION: $e');
    //   // Navigator.of(context).pushNamed(ErrorScreen.routeNamed);
    //   return [];
    // }
    catch (e) {
      log('MAN-CAT-FETCH: $e');
      showSnackBar(context: context, text: '$e');
      // return [];
      rethrow;
    }
  }
}
