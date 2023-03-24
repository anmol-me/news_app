import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:news_app/features/authentication/repository/auth_repo.dart';
import 'package:news_app/features/home/screens/home_feed_screen.dart';

import '../../../common/backend_methods.dart';
import '../../../common/common_widgets.dart';
import '../../../models/model.dart';

Map<int, String> errorMessages = {
  400: "Please check your Url",
  401: "You don't have authorization",
  403: "Forbidden request",
  404: "Could not find feed",
  500: "Server error. Could not complete your request",
};

// const error400 = "Please check your Url";
// const error401 = "You don't have authorization";
// const error403 = "Forbidden request";
// const error500 = "Unable to reach your website";

final feedIdProvider = StateProvider((ref) => []);

final addNewSubscriptionProvider = StateNotifierProvider.autoDispose<
    AddNewSubscriptionNotifier, List<AddNewSubscription>>(
  (ref) {
    ref.onDispose(() {
      print('Discover disposed');
    });
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

      log('Discover-> POST -> Code: ${res.statusCode}');
      catchServerErrorDiscovery(res: res, context: context);
      // ServerErrorDiscoveryException(context, res).throwException();
      log('Will it be executed?');
      if (res.statusCode == 200) {
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
      } // 200

      // catchServerErrorDiscovery(res: res, context: context);

      // else if (res.statusCode == 404) {
      //   log('Error is 404');
      //   // showSnackBar(context: context, text: errorMessages[res.statusCode]!);
      // } else if (res.statusCode == 500) {
      //   log('Error is 500');
      //   showSnackBar(context: context, text: errorMessages[res.statusCode]!);
      //   return;
      // }
    } on TimeoutException catch (e) {
      log('CAT-DISC: $e');
      showSnackBar(
          context: context,
          text: 'Connection Timeout. Could not connect to the server');
    } on ServerErrorDiscoveryException catch (e) {
      log('Server Catch: ${e}');
      showSnackBar(context: context, text: '${e}');
    } catch (e) {
      log('General Catch');
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
        context.pushNamed(HomeFeedScreen.routeNamed);
        // Todo: Nav
        // Navigator.of(context).pushNamed(HomeFeedScreen.routeNamed);
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

// /// Create Category
// Future<void> createCategory(
//   String categoryTitle,
//   BuildContext context,
// ) async {
//   final scaffoldMessenger = ScaffoldMessenger.of(context);
//   final navigator = Navigator.of(context);
//   final themeCxt = Theme.of(context);
//   final ctx = context;
//
//   try {
//     final res = await postHttpResp(
//       uri: null,
//       userPassEncoded: userPassEncoded,
//       url: Uri.parse('https://$url/v1/categories'),
//       bodyMap: {"title": categoryTitle},
//     );
//
//     log('${res.statusCode}');
//
//     // Map decodedData = jsonDecode(res.body);
//
//     if (res.statusCode == 400) {
//       scaffoldMessenger.showSnackBar(
//         SnackBar(
//           behavior: SnackBarBehavior.floating,
//           duration: const Duration(seconds: 10),
//           backgroundColor: themeCxt.errorColor,
//           content: Text(ErrorString.catAlreadyExists.value),
//         ),
//       );
//     }
//
//     showSnackBar(context: context, text: ErrorString.catCreated.value);
//     navigator.pop();
//     state = state;
//   } on TimeoutException catch (e) {
//     log('Timeout Error: $e');
//   } on SocketException catch (e) {
//     log('Socket Error: $e');
//
//     showSnackBar(
//       context: context,
//       text: 'Please check Internet Connectivity',
//     );
//   } catch (e) {
//     log('UPDATE-SUBS: $e');
//     showSnackBar(context: context, text: '$e');
//   }
// }

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

void catchServerError({
  required Response res,
  required BuildContext context,
}) {
  if (res.statusCode >= 400 && res.statusCode <= 599) {
    showSnackBar(context: context, text: errorMessages[res.statusCode]!);
    return;
  }
}

void catchServerErrorDiscovery({
  required Response res,
  required BuildContext context,
}) {
  if (res.statusCode == 404) {
    log('Hey 404');
    showSnackBar(context: context, text: errorMessages[res.statusCode]!);
    return;
  } else if (res.statusCode == 500) {
    log('Hey 500');
    // return;
    throw ServerErrorDiscoveryException(res);
  } else if (res.statusCode >= 400 && res.statusCode <= 599) {
    log('Hey 400 to 600');
    showSnackBar(context: context, text: errorMessages[res.statusCode]!);
    return;
  }
}

class ServerErrorDiscoveryException implements Exception {
  // final BuildContext context;
  final Response res;

  ServerErrorDiscoveryException(
    // this.context,
    this.res,
  );

  @override
  String toString() => errorMessages[res.statusCode]!;

// void throwException() {
//   if (res.statusCode == 404) {
//     log('Hey 404');
//     showSnackBar(context: context, text: errorMessages[res.statusCode]!);
//     throw ServerErrorDiscoveryException(context, res);
//   } else if (res.statusCode == 500) {
//     log('Hey 500');
//     showSnackBar(context: context, text: errorMessages[res.statusCode]!);
//     throw ServerErrorDiscoveryException(context, res);
//   } else if (res.statusCode >= 400 && res.statusCode <= 599) {
//     log('Hey 400 to 600');
//     showSnackBar(context: context, text: errorMessages[res.statusCode]!);
//     throw ServerErrorDiscoveryException(context, res);
//   }
// }
}
