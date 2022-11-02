import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/features/authentication/repository/auth_repo.dart';
import 'package:news_app/features/subscription/repository/category_list_repo.dart';
import 'package:news_app/features/home/screens/home_feed_screen.dart';
import 'package:news_app/features/subscription/screens/select_subscription_screen.dart';
import 'package:news_app/widgets/snack_bar.dart';

import '../../../common/backend_methods.dart';
import '../../../common/common_widgets.dart';
import '../../../common/enums.dart';
import '../../authentication/screens/auth_screen.dart';
import 'category_repo.dart';

Map<int, String> errorMessages = {
  400: "Please check your Url",
  401: "You don't have authorization",
  403: "Forbidden request",
  500: "Unable to reach your website",
};

// const error400 = "Please check your Url";
// const error401 = "You don't have authorization";
// const error403 = "Forbidden request";
// const error500 = "Unable to reach your website";

final feedIdProvider = StateProvider((ref) => []);

class AddNewSubscription {
  final String title;
  final String url;

  AddNewSubscription({
    required this.title,
    required this.url,
  });

// DiscoverSubscription copyWith(
//   String? title,
//   String? url,
// ) {
//   return DiscoverSubscription(
//     title: title ?? this.title,
//     url: url ?? this.url,
//   );
// }
}

final addNewSubscriptionProvider =
    StateNotifierProvider<AddNewSubscriptionNotifier, List<AddNewSubscription>>(
  (ref) {
    final userPrefs = ref.watch(userPrefsProvider);
    final userPassEncoded = userPrefs.getAuthData();
    final url = userPrefs.getUrlData();

    return AddNewSubscriptionNotifier(
      ref,
      userPrefs,
      userPassEncoded!,
      url!,
    );
  },
);

class AddNewSubscriptionNotifier
    extends StateNotifier<List<AddNewSubscription>> {
  final StateNotifierProviderRef ref;
  final UserPreferences userPrefs;
  final String userPassEncoded;
  final String url;

  AddNewSubscriptionNotifier(
    this.ref,
    this.userPrefs,
    this.userPassEncoded,
    this.url,
  ) : super([]);

  /// Discover
  Future<void> discover(
    String checkUrl,
    context,
  ) async {
    if (userPassEncoded.isEmpty && url.isEmpty) return;

    try {
      final res = await postHttpResp(
        uri: null,
        url: Uri.parse('https://$url/v1/discover'),
        userPassEncoded: userPassEncoded,
        bodyMap: {"url": checkUrl},
      );

      log('${res.statusCode}');
      catchServerError(res: res, context: context);

      List<dynamic> decodedData = jsonDecode(res.body);

      final List<AddNewSubscription> fetchedCategoryList = [];

      for (var i = 0; i < decodedData.length; i++) {
        // log('Cat: ${decodedData[i]}');
        var info = decodedData[i];

        final fetchedCategory = AddNewSubscription(
          title: info['title'],
          url: info['url'],
        );

        fetchedCategoryList.add(fetchedCategory);
      }
      state = fetchedCategoryList;
    } on TimeoutException catch (e) {
      log('CAT-DISC: $e');
      showSnackBar(
          context: context,
          text: 'Connection Timeout. Could not connect to the server');
    } catch (e) {
      log('CAT-DISC: $e');
      showSnackBar(context: context, text: 'An Error Occurred');
    }
  }

  Future<void> createFeed(
    BuildContext context,
    String selectedCategory,
    String subscriptionUrl,
    int id,
  ) async {
    log('$selectedCategory');
    log('$subscriptionUrl');
    log('${id}');

    // Uri url = Uri.parse('https://read.rusi.me/v1/feeds');

    Uri uri = Uri.https(url, 'v1/feeds', {
      "feed_url": subscriptionUrl,
      "category_id": id,
    });

    try {
      // http.Response res = await http.post(
      //   url,
      //   headers: {
      //     'Content-Type': 'application/json; charset=UTF-8',
      //     'X-Auth-Token': '-5YfpcHn8F__jMhC0MFA-AaMrqLl5ehBaesPuvjCOzg=',
      //   },
      //   body: json.encode(
      //     {
      //       "feed_url": subscriptionUrl,
      //       "category_id": id,
      //     },
      //   ),
      // );

      final res = await postHttpResp(
        url: null,
        bodyMap: null,
        uri: uri,
        userPassEncoded: userPassEncoded,
      );

      catchServerError(res: res, context: context);

      if (res.statusCode == 201) {
        Map<String, dynamic> decodedData = jsonDecode(res.body);

        final feedId = decodedData.values.toList();

        ref.read(feedIdProvider.notifier).update((state) => feedId);

        showSnackBar(context: context, text: 'Subscription successfully Added');

        if (!mounted) return;
        Navigator.of(context).pushNamed(HomeFeedScreen.routeNamed);
      } else {
        Map<String, dynamic> decodedData = jsonDecode(res.body);

        log('E: $decodedData');
        log('ES: ${res.statusCode}');

        showSnackBar(context: context, text: '${decodedData.values}');
      }
    } catch (e) {
      log('CR-SUBS: $e');
      showSnackBar(context: context, text: '$e');
    }
  }

  Future<void> updateFeed(
    BuildContext context,
    int id,
    String newCategoryTitle,
  ) async {
    // log('${id}');

    String? basicAuth = userPrefs.getAuthData();

    if (basicAuth == null) {
      Navigator.of(context).pushNamed(AuthScreen.routeNamed);

      showSnackBar(
        context: context,
        text: 'Something went wrong! Please login again',
      );
    }

    Uri url = Uri.parse('https://read.rusi.me/v1/categories/$id');

    try {
      http.Response res = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          // 'X-Auth-Token': '-5YfpcHn8F__jMhC0MFA-AaMrqLl5ehBaesPuvjCOzg=',
          'authorization': basicAuth!,
        },
        body: json.encode({
          "title": newCategoryTitle,
        }),
      );

      if (res.statusCode == 201) {
        if (!mounted) return;
        Navigator.of(context).pop();

        showSnackBar(
          context: context,
          text: 'Name changed to $newCategoryTitle',
        );

        if (!mounted) return;
        Navigator.of(context)
            .pushReplacementNamed(SelectSubscriptionScreen.routeNamed);

        // if (!mounted) return;
        // Navigator.of(context).pop();
      } else {
        log('UPDATE-SUBS-else');

        showSnackBar(
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

  Future<void> deleteFeed(
    BuildContext context,
    int id,
    String newCategoryTitle,
  ) async {
    // log('${id}');

    Uri url = Uri.parse('https://read.rusi.me/v1/categories/$id');

    try {
      http.Response res = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'X-Auth-Token': '-5YfpcHn8F__jMhC0MFA-AaMrqLl5ehBaesPuvjCOzg=',
        },
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      if (res.statusCode == 204) {
        showSnackBar(
          context: context,
          text: 'Successfully deleted $newCategoryTitle',
        );

          state = [
            for (final item in state)
              if (item.id != todoId) todo,
          ];


      } else {
        log('UPDATE-SUBS-else');

        showSnackBar(
          context: context,
          text: 'Deletion unsuccessful',
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

  /// Create Category
  Future<void> createCategory(
    String categoryTitle,
    BuildContext context,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final themeCxt = Theme.of(context);
    final ctx = context;

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

      showSnackBar(context: context, text: ErrorString.catCreated.value);
      navigator.pop();
      state = state;
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

// Future<List<NewsCategory>> getCategories(BuildContext context) async {
//
//   String? basicAuth = userPrefs.getAuthData();
//
//   if (basicAuth == null) {
//     Navigator.of(context).pushNamed(AuthScreen.routeNamed);
//
//     showSnackBar(
//       context: context,
//       content: 'Something went wrong! Please login again',
//     );
//   }
//
//   Uri url = Uri.parse('https://read.rusi.me/v1/categories');
//
//   http.Response res = await http.get(
//     url,
//     headers: {
//       'Content-Type': 'application/json; charset=UTF-8',
//       'X-Auth-Token': '-5YfpcHn8F__jMhC0MFA-AaMrqLl5ehBaesPuvjCOzg=',
//     },
//   );
//
//   List<dynamic> decodedData = jsonDecode(res.body);
//
//   // log('$decodedData');
//
//   final List<NewsCategory> fetchedCategoryList = [];
//
//   for (var i = 0; i < decodedData.length; i++) {
//     // log('Cat: ${decodedData[i]}');
//     var info = decodedData[i];
//
//     final fetchedCategory = NewsCategory(
//       entryId: info['id'],
//       title: info['title'],
//       userId: info['user_id'],
//     );
//
//     fetchedCategoryList.add(fetchedCategory);
//
//     // log('${fetchedCategoryList[0].title}');
//
//   }
//   // state = [...state, ...fetchedCategoryList];
//   return fetchedCategoryList;
// }

//
}

void catchServerError({required res, required context}) {
  if (res.statusCode >= 400 && res.statusCode <= 599) {
    showSnackBar(context: context, text: errorMessages[res.statusCode]!);
    return;
  }
}
