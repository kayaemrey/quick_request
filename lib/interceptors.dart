import 'dart:io';
import 'package:quick_request/quick_client.dart';

abstract class QuickInterceptor {
  Future<void> onRequest(RequestOptions options) async {}
  Future<void> onResponse(ResponseOptions options) async {}
  Future<void> onError(RequestError error) async {}
}

/// Loglama interceptor
class LoggingInterceptor extends QuickInterceptor {
  @override
  Future<void> onRequest(RequestOptions options) async {
    print("[REQ] ${options.method} ${options.uri}");
    print("Headers: ${options.headers}");
    if (options.body != null) print("Body: ${options.body}");
  }

  @override
  Future<void> onResponse(ResponseOptions options) async {
    print("[RES] Status: ${options.statusCode} | Uri: ${options.uri}");
    print("Body: ${options.body}");
  }

  @override
  Future<void> onError(RequestError error) async {
    print("[ERR] ${error.message} | Uri: ${error.options.uri}");
  }
}

/// JWT Refresh interceptor örneği
class JwtRefreshInterceptor extends QuickInterceptor {
  final Future<String?> Function() getAccessToken;
  final Future<String?> Function() refreshToken;

  String? _latestToken;

  JwtRefreshInterceptor({
    required this.getAccessToken,
    required this.refreshToken,
  });

  @override
  Future<void> onRequest(RequestOptions options) async {
    final token = _latestToken ?? await getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
  }

  @override
  Future<void> onError(RequestError error) async {
    if (error.statusCode == 401) {
      final newToken = await refreshToken();
      if (newToken != null && newToken.isNotEmpty) {
        _latestToken = newToken;
        // Retry işareti koyulabilir
        error.shouldRetry = true;
        error.retryToken = newToken;
      }
    }
  }
}
