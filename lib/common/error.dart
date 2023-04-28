import 'package:http/http.dart';

import 'enums.dart';

Map<int, String> errorMessages = {
  400: ErrorString.validUrl.value,
  401: ErrorString.accessDenied.value,
  403: ErrorString.generalError.value, // "Forbidden request",
  404: ErrorString.generalError.value, // "Could not find feed",
  500: ErrorString.socket.value,
};

class ServerErrorException implements Exception {
  final Response res;

  ServerErrorException(this.res);

  @override
  String toString() =>
      errorMessages[res.statusCode] ?? ErrorString.somethingWrongAdmin.value;
}
