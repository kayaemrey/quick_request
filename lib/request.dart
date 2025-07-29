import 'dart:convert';
import 'dart:io';
import 'models/response_model.dart';
import 'interceptor.dart';

enum RequestMethod {
  GET,
  POST,
  PUT,
  PATCH,
  DELETE,
}

class QuickRequest {
  final List<QuickRequestInterceptor> interceptors;

  QuickRequest({this.interceptors = const []});

  Future<ResponseModel> request({
    required String url,
    String? bearerToken,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    RequestMethod requestMethod = RequestMethod.GET,
    bool expectJsonArray = false,
    bool retry = false, // JWT refresh için
  }) async {
    var headers = <String, String>{};
    if (bearerToken != null && bearerToken.isNotEmpty) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $bearerToken';
    }
    if (requestMethod != RequestMethod.GET) {
      headers[HttpHeaders.contentTypeHeader] = 'application/json';
    }

    var uri = Uri.parse(url);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    var client = HttpClient();

    try {
      HttpClientRequest request = await _createRequest(client, requestMethod, uri);

      // Header'ları ekle
      headers.forEach((key, value) {
        request.headers.set(key, value);
      });

      // Interceptor: onRequest
      for (final interceptor in interceptors) {
        await interceptor.onRequest(request);
      }

      // Body'yi ekle
      if (body != null &&
          (requestMethod == RequestMethod.POST ||
              requestMethod == RequestMethod.PUT ||
              requestMethod == RequestMethod.PATCH)) {
        request.add(utf8.encode(json.encode(body)));
      }

      HttpClientResponse response = await request.close();

      // Interceptor: onResponse
      for (final interceptor in interceptors) {
        await interceptor.onResponse(response);
      }

      // JWT refresh için 401 kontrolü
      if (response.statusCode == 401 && !retry) {
        // Interceptor'lerden biri bir refresh işlemi başlatabilir
        String? refreshedToken;
        for (final interceptor in interceptors) {
          if (interceptor is JwtRefreshInterceptor) {
            refreshedToken = await interceptor.refreshTokenFunc();
            break;
          }
        }
        if (refreshedToken != null && refreshedToken.isNotEmpty) {
          // Aynı isteği yeni token ile tekrar gönder
          return await this.request(
            url: url,
            bearerToken: refreshedToken,
            body: body,
            queryParameters: queryParameters,
            requestMethod: requestMethod,
            expectJsonArray: expectJsonArray,
            retry: true,
          );
        }
      }

      var responseBody = await response.transform(utf8.decoder).join();
      var jsonData = json.decode(responseBody);

      if (expectJsonArray && jsonData is List) {
        return ResponseModel(
          data: jsonData,
          error: false,
          message: 'Success',
        );
      }

      return ResponseModel(
        data: jsonData['data'],
        error: jsonData['error'] ?? false,
        message: jsonData['message'] ?? 'Success',
      );
    } catch (e) {
      // Interceptor: onError
      for (final interceptor in interceptors) {
        await interceptor.onError(e);
      }
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

/// JWT Refresh interceptor örneği
class JwtRefreshInterceptor extends QuickRequestInterceptor {
  /// Güncel access token'ı getir
  final Future<String?> Function() getAccessToken;
  /// Yeni access token almak için refresh işlemi
  final Future<String?> Function() refreshToken;
  String? _latestToken;

  JwtRefreshInterceptor({
    required this.getAccessToken,
    required this.refreshToken,
  });

  /// QuickRequest 401 aldığında bu fonksiyonu çağırır
  Future<String?> refreshTokenFunc() async {
    _latestToken = await refreshToken();
    return _latestToken;
  }

  @override
  Future<void> onRequest(HttpClientRequest request) async {
    final token = _latestToken ?? await getAccessToken();
    if (token != null && token.isNotEmpty) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
  }

  @override
  Future<void> onResponse(HttpClientResponse response) async {
    // Burada ekstra bir şey yapmana gerek yok, 401 olursa QuickRequest tekrar çağıracak
  }

  @override
  Future<void> onError(Object error) async {
    // Hata loglama veya özel yönetim yapılabilir
  }
}
