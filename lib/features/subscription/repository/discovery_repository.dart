import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/common/enums.dart';

import '../../../common/backend_methods.dart';
import '../../../common/common_widgets.dart';
import '../../../common/error.dart';
import '../../../models/model.dart';
import '../../authentication/repository/user_preferences.dart';
import '../screens/add_subscription_screen.dart';

final discoveryProvider =
    NotifierProvider.autoDispose<DiscoveryNotifier, List<DiscoverSubscription>>(
  DiscoveryNotifier.new,
);

class DiscoveryNotifier
    extends AutoDisposeNotifier<List<DiscoverSubscription>> {
  late UserPreferences userPrefs;
  late String userPassEncoded;
  late String baseUrl;

  @override
  List<DiscoverSubscription> build() {
    userPrefs = ref.watch(userPrefsProvider);
    userPassEncoded = userPrefs.getAuthData()!;
    baseUrl = userPrefs.getUrlData()!;
    return [];
  }

  Future<void> discover(
    String checkUrl,
    BuildContext context,
  ) async {
    try {
      final res = await postHttpResp(
        uri: null,
        url: Uri.parse('https://$baseUrl/v1/discover'),
        userPassEncoded: userPassEncoded,
        bodyMap: {"url": checkUrl},
      );

      if (res.statusCode >= 400 && res.statusCode <= 599) {
        throw ServerErrorException(res);
      }

      if (res.statusCode == 200) {
        List<dynamic> decodedData = jsonDecode(res.body);

        final fetchedCategories =
            decodedData.map((e) => DiscoverSubscription.fromJson(e)).toList();

        state = fetchedCategories;
      }
    } on TimeoutException catch (_) {
      showErrorSnackBar(
          context: context, text: ErrorString.requestTimeout.value);
    } on ServerErrorException catch (e) {
      showErrorSnackBar(context: context, text: '$e');
    } catch (e) {
      showErrorSnackBar(context: context, text: ErrorString.generalError.value);
    }
  }

  void discoverFunction(
    TextEditingController urlController,
    BuildContext context,
  ) {
    final discoverSubscriptionController = ref.read(discoveryProvider.notifier);

    final isDiscoverLoadingController =
        ref.read(isDiscoverLoadingProvider.notifier);

    if (urlController.text.isEmpty) {
      showErrorSnackBar(context: context, text: ErrorString.validUrl.value);
      return;
    }

    isDiscoverLoadingController.update((state) => true);

    discoverSubscriptionController
        .discover(
          urlController.text,
          context,
        )
        .then(
          (_) => isDiscoverLoadingController.update((state) => false),
        );
  }

  Future<void> createFeed(
    BuildContext context,
    String selectedCategory,
    String subscriptionUrl,
    int catId,
  ) async {
    try {
      final res = await postHttpResp(
        url: Uri.parse('https://$baseUrl/v1/feeds'),
        bodyMap: {
          "feed_url": subscriptionUrl,
          "category_id": catId,
        },
        uri: null,
        userPassEncoded: userPassEncoded,
      );

      if (res.statusCode >= 400 && res.statusCode <= 599) {
        throw ServerErrorException(res);
      }

      if (res.statusCode == 201) {
        if (context.mounted) {
          showSnackBar(context: context, text: Message.feedAdded.value);
        }

        if (context.mounted) context.pop();
      } else {
        Map<String, dynamic> decodedData = jsonDecode(res.body);

        if (context.mounted) {
          showErrorSnackBar(context: context, text: '${decodedData.values}');
        }
      }
    } on TimeoutException catch (_) {
      showErrorSnackBar(
          context: context, text: ErrorString.requestTimeout.value);
    } on ServerErrorException catch (e) {
      showErrorSnackBar(context: context, text: '$e');
    } catch (e) {
      showErrorSnackBar(context: context, text: ErrorString.generalError.value);
    }
  }

  void submitFeed(
    BuildContext context,
    ValueNotifier<bool> isLoading,
    DiscoverSubscription subsItem,
    CategoryList selectedCatInfo,
  ) {
    final selectedCategory = ref.read(selectedCategoryProvider);

    final showAsteriskController = ref.read(showAsteriskProvider.notifier);

    ref.read(isFeedLoadingProvider.notifier).update((state) => true);

    if (selectedCategory.isEmpty) {
      showSnackBar(context: context, text: 'Please select category.');
      showAsteriskController.update((state) => true);
      ref.read(isFeedLoadingProvider.notifier).update((state) => false);
      return;
    } else if (selectedCategory.isNotEmpty) {
      showAsteriskController.update((state) => false);
    }

    isLoading.value = true;

    ref
        .read(discoveryProvider.notifier)
        .createFeed(
          context,
          selectedCategory,
          subsItem.url,
          selectedCatInfo.id,
        )
        .then(
      (_) {
        isLoading.value = false;
        ref.read(isFeedLoadingProvider.notifier).update((state) => false);
      },
    );
  }
}
