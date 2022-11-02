import 'dart:convert';
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../common/common_widgets.dart';
import '../common/backend_methods.dart';
import '../features/authentication/repository/auth_repo.dart';
import '../features/authentication/screens/auth_screen.dart';
import '../widgets/snack_bar.dart';

class User {
  final int id;
  final String username;

  User({required this.id, required this.username});

  // User copyWith(int? id, String? username) {
  //   return User(
  //     id: id ?? this.id,
  //     username: username ?? this.username,
  //   );
  // }
}

class UserNotifier extends StateNotifier<List<User>> {

  final UserPreferences userPrefs;
  UserNotifier(this.userPrefs) : super([]);

  Future fetchUserData(BuildContext context) async {
    String? userPassEncoded = userPrefs.getAuthData();
    String? url = userPrefs.getUrlData();

    if (userPassEncoded == null || url == null) {
      Navigator.of(context).pushNamed(AuthScreen.routeNamed);

      showSnackBar(
        context: context,
        text: 'Something went wrong! Please login again',
      );
    }

    try {
      // 'https://read.rusi.me/v1/me'
      Uri uri = Uri.https(url!, 'v1/me', {});

      http.Response res = await getHttpResp(uri, userPassEncoded);

      // Uri url = Uri.parse('https://read.rusi.me/v1/me');

      // http.Response res = await http.get(
      //   url,
      //   headers: {
      //     'Content-Type': 'application/json; charset=UTF-8',
      //     'X-Auth-Token': '-5YfpcHn8F__jMhC0MFA-AaMrqLl5ehBaesPuvjCOzg=',
      //   },
      // );

      Map<String, dynamic> decodedData = jsonDecode(res.body);

      final List<User> fetchedUserList = [];

      // log(decodedData['entries'][0]['status'].toString());

      // fetchedNewsList.add(decodedData['entries']);
      // log(fetchedNewsList[0][0].toString());

      // for (var i = 0; i < decodedData.length; i++) {
      // }

      final currentUser = User(
        id: decodedData['id'],
        username: decodedData['username'],
      );

      // log(currentUser.id.toString());

      return state = [currentUser];
    } catch (e) {
      log('Cannot fetch User Data');
    }
  }
}


