import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:news_app/common/enums.dart';

import '../features/authentication/repository/user_preferences.dart';
import 'error_screen.dart';
import '../features/authentication/screens/auth_screen.dart';
import 'common_widgets.dart';

Future<http.Response> getHttpResp(Uri uri, String userPassEncoded) async =>
    await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': userPassEncoded,
      },
    );

Future<http.Response> putHttpResp({
  String? url,
  Uri? uri,
  Map? bodyMap,
  userPassEncoded,
}) async {
  if (url != null && uri == null) {
    if (bodyMap != null) {
      return await http.put(
        Uri.parse(url),
        body: jsonEncode(
          bodyMap,
        ),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'authorization': userPassEncoded,
        },
      );
    } else {
      return await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'authorization': userPassEncoded,
        },
      );
    }
  } else {
    return await http.put(
      uri!,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': userPassEncoded,
      },
    );
  }
}

Future<http.Response> postHttpResp({
  Uri? url,
  Uri? uri,
  Map? bodyMap,
  userPassEncoded,
}) async {
  if (url != null && bodyMap != null) {

    // Todo: Cleanup
    log('POST 1');
    return await http.post(
      url,
      body: jsonEncode(bodyMap),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': userPassEncoded,
      },
    );
  } else if (url != null) {
    log('POST 2');
    return await http.post(
      Uri.parse('https://$url'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': userPassEncoded,
      },
    );
  } else if (uri != null) {
    log('POST 3');
    return await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': userPassEncoded,
      },
    );
  }
  log('4: Default');
  return await http.post(
    url!,
    body: jsonEncode(bodyMap),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'authorization': userPassEncoded,
    },
  );
}

void checkAuth(
  BuildContext context,
  String? userPassEncoded,
  String? baseUrl,
  UserPreferences userPrefs,
) {
  if (userPassEncoded == null ||
      userPassEncoded.isEmpty ||
      baseUrl == null ||
      baseUrl.isEmpty) {
    context.pushNamed(AuthScreen.routeNamed);

    /// Todo: Nav
    // Navigator.of(context).pushNamed(AuthScreen.routeNamed);

    userPrefs.clearPrefs();

    showSnackBar(
      context: context,
      text: ErrorString.somethingWrongAuth.value,
    );
  }
}

String getImageUrl(info) {
  // if (info['content']!.contains('img alt')) {

  final imageUrl =
      html_parser.parse(info['content']).getElementsByTagName('img');

  if (imageUrl.isNotEmpty) {
    return imageUrl[0].attributes['src'] ?? '';
  } else {
    return '';
  }
}

DateTime getDateTime(info) {
  var time = info['published_at'];
  int startIndex = time.indexOf('T');
  int endIndex = time.indexOf('Z');

  final timeLoaded = time.substring(startIndex + 1, endIndex + "T".length - 1);
  final dateLoaded = time.substring(0, startIndex);

  return DateTime.parse('$dateLoaded $timeLoaded');
}

void tryCatch(Function() f) {
  try {
    log('Function has run');
    f();
  } on TimeoutException catch (e) {
    log('Timeout Error: $e');
    rethrow;
  } on SocketException catch (e) {
    log('Socket Error: $e');
    rethrow;
  } on Error catch (e) {
    log('General Error: $e');
    rethrow;
  } catch (e) {
    log('All other Errors: $e');
    rethrow;
  }
}
