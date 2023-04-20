import 'package:http/http.dart';

import 'enums.dart';

Map<int, String> errorMessages = {
  400: "Please check your url",
  401: "You don't have authorization",
  403: "Forbidden request",
  404: "Could not find feed",
  500: "Server error. Could not complete your request",
};

class ServerErrorException implements Exception {
  final Response res;

  ServerErrorException(this.res);

  @override
  String toString() =>
      errorMessages[res.statusCode] ?? ErrorString.somethingWrongAdmin.value;
}
