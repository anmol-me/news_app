import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'package:http/http.dart' as http;

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