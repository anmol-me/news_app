import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:news_app/common/api_methods.dart';
import 'package:universal_platform/universal_platform.dart';
import '../../../common/file_repository.dart';
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

  @override
  List<CategoryList> build() {
    userPrefs = ref.watch(userPrefsProvider);
    return [];
  }

  void clearState() => state.clear();

  Future<List<CategoryList>> fetchCategories(
    BuildContext context,
  ) async {
    try {
      final userPassEncoded = userPrefs.getAuthData()!;
      final baseUrl = userPrefs.getUrlData()!;

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
  ) async {
    try {
      final fileRepository = ref.read(fileRepositoryProvider);

      final cacheData = await fileRepository.readFile(
        AssetFileName.categories.value,
      );

      List<dynamic> decodedData = jsonDecode(cacheData);

      List<CategoryList> fetchedCategories =
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
    if (categoryTitle == '') {
      showErrorSnackBar(
        context: context,
        text: ErrorString.emptyField.value,
      );
      Navigator.of(context).pop();
      return;
    }

    try {
      final userPassEncoded = userPrefs.getAuthData()!;
      final baseUrl = userPrefs.getUrlData()!;

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

          showErrorSnackBar(
            context: context,
            text: ErrorString.catAlreadyExists.value,
            duration: const Duration(seconds: 10),
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

  Future<void> createDemoCategory(
    String categoryTitle,
    BuildContext context,
  ) async {
    if (UniversalPlatform.isWeb) {
      Navigator.of(context).pop();
      showErrorSnackBar(
        context: context,
        text: ErrorString.limitedDemoWebSupport.value,
      );
      return;
    }

    try {
      final fileRepository = ref.read(fileRepositoryProvider);

      final item = CategoryList(
        id: Random().nextInt(1000),
        title: categoryTitle,
      );

      await fileRepository.writeToFile(
        data: json.encode([...state, item]),
        assetName: AssetFileName.categories.value,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
        showSnackBar(context: context, text: Message.catCreated.value);
      }

      state = [...state, item];
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

    try {
      final userPassEncoded = userPrefs.getAuthData()!;
      final baseUrl = userPrefs.getUrlData()!;

      Uri uri = Uri.https(baseUrl, 'v1/categories/$catId');
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

  Future<void> deleteDemoCategory(
    int catId,
    String catTitle,
    BuildContext context,
  ) async {
    if (UniversalPlatform.isWeb) {
      showErrorSnackBar(
        context: context,
        text: ErrorString.limitedDemoWebSupport.value,
      );
      return;
    }

    try {
      final fileRepository = ref.read(fileRepositoryProvider);

      state = [
        for (final item in state)
          if (item.id != catId) item,
      ];

      await fileRepository.writeToFile(
        data: json.encode(state),
        assetName: AssetFileName.categories.value,
      );

      if (context.mounted) {
        showSnackBar(
          context: context,
          text: 'Successfully deleted $catTitle',
        );
      }
    } catch (e) {
      showErrorSnackBar(context: context, text: ErrorString.generalError.value);
    }
  }

  Future<void> updateCategoryName(
    BuildContext context,
    GlobalKey<FormState> formKey,
    int id,
    String newCategoryTitle,
  ) async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      final userPassEncoded = userPrefs.getAuthData()!;
      final baseUrl = userPrefs.getUrlData()!;

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

  Future<void> updateDemoCategoryName(
    BuildContext context,
    GlobalKey<FormState> formKey,
    String newCategoryTitle,
    String oldTitle,
  ) async {
    if (UniversalPlatform.isWeb) {
      Navigator.of(context).pop();
      showErrorSnackBar(
        context: context,
        text: ErrorString.limitedDemoWebSupport.value,
      );
      return;
    }

    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      final fileRepository = ref.read(fileRepositoryProvider);

      state = [
        for (final item in state)
          if (item.title == oldTitle)
            item.copyWith(title: newCategoryTitle)
          else
            item,
      ];

      await fileRepository.writeToFile(
        data: json.encode(state),
        assetName: AssetFileName.categories.value,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
        showSnackBar(
          context: context,
          text: 'Name changed to $newCategoryTitle',
        );
      }
    } catch (e) {
      showErrorSnackBar(context: context, text: ErrorString.generalError.value);
    }
  }
}
