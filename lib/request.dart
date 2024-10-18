import 'dart:convert';
import 'dart:io';
import 'models/response_model.dart';

enum RequestMethod {
  GET,
  POST,
  PUT,
  PATCH,
  DELETE,
}

class QuickRequest {
  Future<ResponseModel> request({
    required String url,
    String? bearerToken,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    RequestMethod requestMethod = RequestMethod.GET,
    bool authorize = false,
    bool expectJsonArray = false,
  }) async {
    var headers = <String, String>{};
    if (bearerToken != null && bearerToken.isNotEmpty) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $bearerToken';
    }
    if (requestMethod != RequestMethod.GET) {
      headers[HttpHeaders.contentTypeHeader] = 'application/json';
    }

    // URI ve query params
    var uri = Uri.parse(url);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    var client = HttpClient();

    try {
      HttpClientRequest request = await _createRequest(client, requestMethod, uri);

      // Header'ları tek tek ekleyelim
      headers.forEach((key, value) {
        request.headers.set(key, value);
      });

      // Body'yi ekleyelim
      if (body != null && (requestMethod == RequestMethod.POST || requestMethod == RequestMethod.PUT || requestMethod == RequestMethod.PATCH)) {
        request.add(utf8.encode(json.encode(body)));
      }

      // Response'u alalım
      HttpClientResponse response = await request.close();

      // Yanıtı işle
      var responseBody = await response.transform(utf8.decoder).join();
      var jsonData = json.decode(responseBody);

      // Eğer array bekleniyorsa, kontrol yap
      if (expectJsonArray && jsonData is List) {
        return ResponseModel(
          data: jsonData,
          error: false,
          message: 'Success',
        );
      }

      // Eğer "data" varsa onu al, yoksa direkt jsonData
      var actualData = jsonData is Map<String, dynamic> && jsonData.containsKey('data') ? jsonData['data'] : jsonData;

      return ResponseModel(
        data: actualData,
        error: jsonData['error'] ?? false,
        message: jsonData['message'] ?? 'Success',
      );
    } catch (e) {
      return ResponseModel(
        data: null,
        error: true,
        message: e.toString(),
      );
    } finally {
      client.close();
    }
  }

  Future<HttpClientRequest> _createRequest(
    HttpClient client,
    RequestMethod requestMethod,
    Uri uri,
  ) async {
    switch (requestMethod) {
      case RequestMethod.POST:
        return await client.postUrl(uri);
      case RequestMethod.PUT:
        return await client.putUrl(uri);
      case RequestMethod.PATCH:
        return await client.patchUrl(uri);
      case RequestMethod.DELETE:
        return await client.deleteUrl(uri);
      case RequestMethod.GET:
      default:
        return await client.getUrl(uri);
    }
  }
}
