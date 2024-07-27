// ignore_for_file: constant_identifier_names

part of 'quick_request.dart';

enum RequestMethod {
  GET,
  POST,
  PUT,
  PATCH,
  DELETE,
}

class QuickRequest {
  Future<ResponseModel> request({
    String url = '',
    String? bearerToken,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    RequestMethod requestMethod = RequestMethod.GET,
    bool authorize = false,
  }) async {
    var headers = <String, String>{};

    if (bearerToken != null && bearerToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }

    if (requestMethod == RequestMethod.POST || requestMethod == RequestMethod.PUT || requestMethod == RequestMethod.PATCH) {
      headers['Content-Type'] = 'application/json';
    }

    var uri = Uri.parse(url);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    var request = http.Request(requestMethod.name, uri);

    if (requestMethod == RequestMethod.POST || requestMethod == RequestMethod.PUT || requestMethod == RequestMethod.PATCH) {
      request.body = json.encode(body);
    }

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var jsonData = json.decode(responseBody);
      return ResponseModel(
        data: jsonData["data"],
        error: jsonData['error'] ?? false,
        message: jsonData['message'] ?? "",
      );
    } else {
      var responseBody = await response.stream.bytesToString();
      var jsonData = json.decode(responseBody);
      return ResponseModel(
        data: null,
        error: true,
        message: jsonData['message'] ?? 'Failed to load data',
      );
    }
  }
}
