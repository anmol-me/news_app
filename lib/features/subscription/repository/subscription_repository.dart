import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/common/api_methods.dart';

import '../../../common_widgets/common_widgets.dart';
import '../../../common/enums.dart';
import '../../../common/error.dart';
import '../../../models/model.dart';
import '../../authentication/repository/user_preferences.dart';

final isDeletingCatProvider = StateProvider((ref) => false);

final subscriptionNotifierProvider =
    NotifierProvider<SubscriptionNotifier, List<CategoryList>>(
  SubscriptionNotifier.new,
);

class SubscriptionNotifier extends Notifier<List<CategoryList>> {
  late UserPreferences userPrefs;
  late String userPassEncoded;
  late String baseUrl;

  @override
  List<CategoryList> build() {
    userPrefs = ref.watch(userPrefsProvider);
    userPassEncoded = userPrefs.getAuthData()!;
    baseUrl = userPrefs.getUrlData()!;
    return [];
  }

  Future<List<CategoryList>> fetchCategories(
    BuildContext context,
  ) async {
    try {
      Uri uri = Uri.https(baseUrl, 'v1/categories');

      final res = await getHttpResp(uri, userPassEncoded);

      if (res.contentLength == 0) {
        if (context.mounted) {
          Navigator.of(context).pop();

          showErrorSnackBar(
            context: context,
            text: ErrorString.socket.value,
          );
        }
        return [];
      }

      if (res.statusCode >= 400 && res.statusCode <= 599) {
        throw ServerErrorException(res);
      }

      List<dynamic> decodedData = jsonDecode(res.body);

      final fetchedCategories =
          decodedData.map((e) => CategoryList.fromJson(e)).toList();

      return state = fetchedCategories;
    } on SocketException catch (_) {
      showErrorSnackBar(
        context: context,
        text: ErrorString.checkInternet.value,
      );
      return [];
    } on TimeoutException catch (_) {
      showErrorSnackBar(
        context: context,
        text: ErrorString.requestTimeout.value,
      );
      return [];
    } on ServerErrorException catch (e) {
      showErrorSnackBar(context: context, text: '$e');
      return [];
    } catch (_) {
      showErrorSnackBar(
        context: context,
        text: ErrorString.generalError.value,
      );
      return [];
    }
  }

  Future<List<CategoryList>> fetchDemoCategories(
      BuildContext context,
      AssetBundle bundle,
      ) async {
    try {
      String data = await bundle.loadString(
        'assets/demo_files/categories.json',
      );

      List<dynamic> decodedData = jsonDecode(data);

      final fetchedCategories =
      decodedData.map((e) => CategoryList.fromJson(e)).toList();

      return state = fetchedCategories;
    } catch (_) {
      showErrorSnackBar(
        context: context,
        text: ErrorString.generalError.value,
      );
      return [];
    }
  }

  Future<void> createCategory(
    String categoryTitle,
    BuildContext context,
  ) async {
    await Future.delayed(const Duration(seconds: 5));
    try {
      final res = await postHttpResp(
        uri: null,
        userPassEncoded: userPassEncoded,
        url: Uri.parse('https://$baseUrl/v1/categories'),
        bodyMap: {"title": categoryTitle},
      );

      if (res.statusCode == 400) {
        if (context.mounted) {
          // Pops bottom sheet for creating category
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 10),
              backgroundColor: Theme.of(context).colorScheme.error,
              content: Text(ErrorString.catAlreadyExists.value),
            ),
          );
        }
        return;
      }

      if (res.statusCode >= 401 && res.statusCode <= 599) {
        throw ServerErrorException(res);
      }

      final decodedData = jsonDecode(res.body);

      final categoryListItem = CategoryList(
        id: decodedData['id'],
        title: decodedData['title'],
      );

      if (context.mounted) {
        Navigator.of(context).pop();
        showSnackBar(context: context, text: Message.catCreated.value);
      }

      state = [...state, categoryListItem];
    } on SocketException catch (_) {
      if (context.mounted) {
        showErrorSnackBar(
            context: context, text: ErrorString.checkInternet.value);
      }
    } on TimeoutException catch (_) {
      if (context.mounted) {
        showErrorSnackBar(
            context: context, text: ErrorString.requestTimeout.value);
      }
    } on ServerErrorException catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context: context, text: '$e');
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(
            context: context, text: ErrorString.generalError.value);
      }
    }
  }

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
        if (listContext.mounted) {
          showSnackBar(
            context: listContext,
            text: 'Successfully deleted $catTitle',
          );
        }
      }
      if (res.statusCode >= 400 && res.statusCode <= 599) {
        throw ServerErrorException(res);
      }
    } on ServerErrorException catch (e) {
      state = [...state]..insert(itemIndex, catItem);

      showErrorSnackBar(context: listContext, text: '$e');
    } on TimeoutException catch (_) {
      state = [...state]..insert(itemIndex, catItem);

      showErrorSnackBar(
          context: listContext,
          text:
              '${ErrorString.catNotDelete.value} ${ErrorString.requestTimeout.value}');
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
    try {
      final res = await putHttpResp(
          uri: null,
          url: 'https://$baseUrl/v1/categories/$id',
          userPassEncoded: userPassEncoded,
          bodyMap: {"title": newCategoryTitle});

      if (res.statusCode == 201) {
        state = [
          for (final item in state)
            if (item.id == id) item.copyWith(title: newCategoryTitle) else item,
        ];

        if (context.mounted) {
          Navigator.of(context).pop();
          showSnackBar(
            context: context,
            text: 'Name changed to $newCategoryTitle',
          );
        }
      } else {
        if (context.mounted) {
          showErrorSnackBar(
            context: context,
            text: 'Name change unsuccessful',
          );
        }
      }
      if (res.statusCode >= 400 && res.statusCode <= 599) {
        throw ServerErrorException(res);
      }
    } on SocketException catch (_) {
      showErrorSnackBar(
          context: context, text: ErrorString.checkInternet.value);
    } on TimeoutException catch (_) {
      showErrorSnackBar(
          context: context, text: ErrorString.requestTimeout.value);
    } on ServerErrorException catch (e) {
      showErrorSnackBar(context: context, text: '$e');
    } catch (e) {
      showErrorSnackBar(context: context, text: ErrorString.generalError.value);
    }
  }
}
