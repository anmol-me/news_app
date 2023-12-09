import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../common/api_methods.dart';
import '../../../common_widgets/common_widgets.dart';
import '../../../common/enums.dart';
import '../../../common/error.dart';
import '../../../models/model.dart';
import '../../authentication/repository/user_preferences.dart';

/// Notifier Provider
final manageCateNotifierProvider =
    NotifierProvider<ManageCategoryRepository, List<CategoryList>>(
  ManageCategoryRepository.new,
);

/// Notifier Class
class ManageCategoryRepository extends Notifier<List<CategoryList>> {
  late UserPreferences userPrefs;

  @override
  List<CategoryList> build() {
    userPrefs = ref.watch(userPrefsProvider);
    return [];
  }

  Future<List<CategoryList>> fetchCategoryFeeds(
    BuildContext context,
    int categoryId,
  ) async {
    final mounted = context.mounted;
    try {
      final userPassEncoded = userPrefs.getAuthData()!;
      final baseUrl = userPrefs.getUrlData()!;

      Uri uri = Uri.https(baseUrl, 'v1/categories/$categoryId/feeds');

      final res = await getHttpResp(uri, userPassEncoded);

      if (res.statusCode >= 400 && res.statusCode <= 599) {
        throw ServerErrorException(res);
      }

      List<CategoryList> fetchedCategories = [];

      if (res.statusCode == 200) {
        List<dynamic> decodedData = jsonDecode(res.body);

        fetchedCategories =
            decodedData.map((e) => CategoryList.fromJson(e)).toList();
      }

      return state = fetchedCategories;
    } on SocketException catch (_) {
      if (mounted) {
        showErrorSnackBar(
            context: context, text: ErrorString.checkInternet.value);
      }
      return [];
    } on TimeoutException catch (_) {
      if (mounted) {
        showErrorSnackBar(
            context: context, text: ErrorString.requestTimeout.value);
      }
      return [];
    } on ServerErrorException catch (e) {
      if (mounted) {
        showErrorSnackBar(context: context, text: '$e');
      }
      return [];
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(
            context: context, text: ErrorString.generalError.value);
      }
      return [];
    }
  }

  /// Delete
  Future<void> deleteCatFeed(
    BuildContext context,
    CategoryList categoryItem,
  ) async {
    final mounted = context.mounted;
    final int itemId = categoryItem.id;
    final String catTitle = categoryItem.title;

    final catItem = state.firstWhere((e) => e.id == itemId);
    final itemIndex = state.indexWhere((e) => e.id == itemId);

    state = [
      for (final item in state)
        if (item.id != itemId) item,
    ];

    final userPassEncoded = userPrefs.getAuthData()!;
    final baseUrl = userPrefs.getUrlData()!;

    Uri uri = Uri.https(baseUrl, 'v1/feeds/$itemId');

    try {
      final res = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'authorization': userPassEncoded,
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
      if (mounted) {
        showErrorSnackBar(
            context: context,
            text:
                '${ErrorString.catNotDelete.value} ${ErrorString.requestTimeout.value}');
      }
    } on SocketException catch (_) {
      state = [...state]..insert(itemIndex, catItem);

      if (mounted) {
        showErrorSnackBar(
          context: context,
          text:
              '${ErrorString.catNotDelete.value} ${ErrorString.checkInternet.value}',
        );
      }
    } catch (e) {
      state = [...state]..insert(itemIndex, catItem);

      if (mounted) showErrorSnackBar(context: context, text: '$e');
    }
  }

  Future<void> updateCatFeedName({
    required BuildContext listContext,
    required int feedId,
    required int catId,
    required String newFeedTitle,
  }) async {
    final mounted = listContext.mounted;
    try {
      final userPassEncoded = userPrefs.getAuthData()!;
      final baseUrl = userPrefs.getUrlData()!;

      final res = await putHttpResp(
          uri: null,
          url: 'https://$baseUrl/v1/feeds/$feedId',
          userPassEncoded: userPassEncoded,
          bodyMap: {
            "title": newFeedTitle,
            "category_id": catId,
          });

      if (res.statusCode == 201) {
        if (listContext.mounted) Navigator.of(listContext).pop();

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
    } on SocketException catch (_) {
      if (mounted) {
        showErrorSnackBar(
            context: listContext, text: ErrorString.checkInternet.value);
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        showErrorSnackBar(
            context: listContext, text: ErrorString.requestTimeout.value);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(
            context: listContext, text: ErrorString.generalError.value);
      }
    }
  }
}
