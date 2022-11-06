import 'dart:convert';
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/features/app_bar/app_drawer.dart';

import '../../common/common_widgets.dart';
import '../../common/backend_methods.dart';
import '../authentication/repository/auth_repo.dart';
import '../authentication/screens/auth_screen.dart';

final usernameProvider = StateProvider((ref) => '');

class User {
  final int id;
  final String username;

  User({
    required this.id,
    required this.username,
  });
}

class UserNotifier extends StateNotifier<User?> {
  final UserPreferences userPrefs;
  final String baseUrl;
  final String userPassEncoded;
  final StateNotifierProviderRef ref;

  UserNotifier(
    this.userPrefs,
    this.baseUrl,
    this.userPassEncoded,
    this.ref,
  ) : super(null);

  Future fetchUserData(BuildContext context) async {
    checkAuth(context, userPassEncoded, baseUrl, userPrefs);

    try {
      // 'https://read.rusi.me/v1/me'
      Uri uri = Uri.https(baseUrl, 'v1/me');

      final res = await getHttpResp(uri, userPassEncoded);

      Map<String, dynamic> decodedData = jsonDecode(res.body);

      final currentUser = User(
        id: decodedData['id'],
        username: decodedData['username'],
      );

      ref.read(usernameProvider.notifier).update(
            (state) => currentUser.username,
          );

      return state = currentUser;
    } catch (e) {
      log('Cannot fetch User Data');
    }
  }
}

// final userNotifierFuture =
//     FutureProvider.family<List<User>, BuildContext>((ref, context) async {
//   //
//   final userPrefs = ref.watch(userPrefsProvider);
//   final baseUrl = userPrefs.getUrlData();
//   final userPassEncoded = userPrefs.getAuthData();
//
//   checkAuth(context, userPassEncoded, baseUrl, userPrefs);
//
//   try {
//     // 'https://read.rusi.me/v1/me'
//     Uri uri = Uri.https(baseUrl!, 'v1/me');
//
//     http.Response res = await getHttpResp(uri, userPassEncoded!);
//
//     Map<String, dynamic> decodedData = jsonDecode(res.body);
//
//     final List<User> fetchedUserList = [];
//
//     // log(decodedData['entries'][0]['status'].toString());
//
//     // fetchedNewsList.add(decodedData['entries']);
//     // log(fetchedNewsList[0][0].toString());
//
//     // for (var i = 0; i < decodedData.length; i++) {
//     // }
//
//     final currentUser = User(
//       id: decodedData['id'],
//       username: decodedData['username'],
//     );
//
//     // log(currentUser.id.toString());
//
//     return [currentUser];
//   } catch (e) {
//     log('Cannot fetch User Data');
//   }
//   return [];
// });
