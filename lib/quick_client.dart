import 'dart:convert';
import 'dart:io';
import 'package:quick_request/interceptors.dart';

import 'models/response_model.dart';
import 'models/exceptions.dart';
import 'types.dart';
import 'utils/cache_manager.dart';

class RequestOptions {
  String method;
  Uri uri;
  Map<String, String> headers;
  dynamic body;
  Duration? timeout;
  ProgressCallback? onProgress;
  bool expectJsonArray;
  Map<String, dynamic>? queryParameters;
  Map<String, dynamic>? pathParams;
  CancelToken? cancelToken;

  RequestOptions({
    required this.method,
    required this.uri,
    this.headers = const {},
    this.body,
    this.timeout,
    this.onProgress,
    this.expectJsonArray = false,
    this.queryParameters,
    this.pathParams,
    this.cancelToken,
  });
}

class ResponseOptions {
  int statusCode;
  dynamic body;
  Uri uri;
  Map<String, String> headers;

  ResponseOptions({
    required this.statusCode,
    required this.body,
    required this.uri,
    required this.headers,
  });
}

class RequestError {
  final String message;
  final int? statusCode;
  final RequestOptions options;
  bool shouldRetry = false;
  String? retryToken;

  RequestError(this.message, this.options, {this.statusCode});
}

class CancelToken {
  bool _cancelled = false;
  void cancel() => _cancelled = true;
  bool get isCancelled => _cancelled;
}

/// Zincirleme QuickRequest API
class QuickRequest {
  final String? baseUrl;
  final List<QuickInterceptor> interceptors;
  final CacheManager? cacheManager;

  String? _path;
  Map<String, dynamic>? _queryParameters;
  Map<String, dynamic>? _pathParams;
  Map<String, String> _headers = {};
  dynamic _body;
  Duration? _timeout;
  ProgressCallback? _onProgress;
  CancelToken? _cancelToken;

  QuickRequest({
    this.baseUrl,
    this.interceptors = const [],
    this.cacheManager,
  });

  /// Zincirleme fonksiyonlar:
  QuickRequest url(String path) {
    _path = path;
    return this;
  }

  QuickRequest query(Map<String, dynamic> params) {
    _queryParameters = params;
    return this;
  }

  QuickRequest pathParams(Map<String, dynamic> params) {
    _pathParams = params;
    return this;
  }

  QuickRequest headers(Map<String, String> headers) {
    _headers.addAll(headers);
    return this;
  }

  QuickRequest body(dynamic body) {
    _body = body;
    return this;
  }

  QuickRequest timeout(Duration duration) {
    _timeout = duration;
    return this;
  }

  QuickRequest onProgress(ProgressCallback callback) {
    _onProgress = callback;
    return this;
  }

  QuickRequest cancelToken(CancelToken token) {
    _cancelToken = token;
    return this;
  }

  void _reset() {
    _path = null;
    _queryParameters = null;
    _pathParams = null;
    _headers = {};
    _body = null;
    _timeout = null;
    _onProgress = null;
    _cancelToken = null;
  }

  /// GET
  Future<ResponseModel<T>> get<T>({
    FromJson<T>? fromJson,
    bool expectJsonArray = false,
    bool useCache = false,
  }) async {
    return await _request<T>(
      RequestMethod.GET,
      fromJson: fromJson,
      expectJsonArray: expectJsonArray,
      useCache: useCache,
    );
  }

  /// POST
  Future<ResponseModel<T>> post<T>({
    FromJson<T>? fromJson,
    bool expectJsonArray = false,
  }) async {
    return await _request<T>(
      RequestMethod.POST,
      fromJson: fromJson,
      expectJsonArray: expectJsonArray,
    );
  }

  /// PUT
  Future<ResponseModel<T>> put<T>({
    FromJson<T>? fromJson,
    bool expectJsonArray = false,
  }) async {
    return await _request<T>(
      RequestMethod.PUT,
      fromJson: fromJson,
      expectJsonArray: expectJsonArray,
    );
  }

  /// PATCH
  Future<ResponseModel<T>> patch<T>({
    FromJson<T>? fromJson,
    bool expectJsonArray = false,
  }) async {
    return await _request<T>(
      RequestMethod.PATCH,
      fromJson: fromJson,
      expectJsonArray: expectJsonArray,
    );
  }

  /// DELETE
  Future<ResponseModel<T>> delete<T>({
    FromJson<T>? fromJson,
    bool expectJsonArray = false,
  }) async {
    return await _request<T>(
      RequestMethod.DELETE,
      fromJson: fromJson,
      expectJsonArray: expectJsonArray,
    );
  }

  /// Ana request fonksiyonu
  Future<ResponseModel<T>> _request<T>(
    RequestMethod method, {
    FromJson<T>? fromJson,
    bool expectJsonArray = false,
    bool useCache = false,
    int retryCount = 0,
  }) async {
    try {
      // Path parametrelerini uygula
      String url = _buildUrl();

      // Query parametreleri ekle
      Uri uri = Uri.parse(url);
      if (_queryParameters != null && _queryParameters!.isNotEmpty) {
        uri = uri.replace(queryParameters: _queryParameters);
      }

      // Cache kontrolü
      if (useCache && cacheManager != null) {
        final cached = cacheManager!.get<ResponseModel<T>>(uri.toString());
        if (cached != null) {
          _reset();
          return cached;
        }
      }

      // RequestOptions hazırla
      final options = RequestOptions(
        method: method.name,
        uri: uri,
        headers: _headers,
        body: _body,
        timeout: _timeout,
        onProgress: _onProgress,
        expectJsonArray: expectJsonArray,
        queryParameters: _queryParameters,
        pathParams: _pathParams,
        cancelToken: _cancelToken,
      );

      // Interceptor: onRequest
      for (final interceptor in interceptors) {
        await interceptor.onRequest(options);
      }

      // İstek gönder
      final httpClient = HttpClient();
      HttpClientRequest request;
      switch (method) {
        case RequestMethod.POST:
          request = await httpClient.postUrl(uri);
          break;
        case RequestMethod.PUT:
          request = await httpClient.putUrl(uri);
          break;
        case RequestMethod.PATCH:
          request = await httpClient.patchUrl(uri);
          break;
        case RequestMethod.DELETE:
          request = await httpClient.deleteUrl(uri);
          break;
        case RequestMethod.GET:
        default:
          request = await httpClient.getUrl(uri);
      }

      _headers.forEach((k, v) => request.headers.set(k, v));

      if (_body != null &&
          (method == RequestMethod.POST ||
              method == RequestMethod.PUT ||
              method == RequestMethod.PATCH)) {
        request.headers.contentType = ContentType.json;
        request.add(utf8.encode(json.encode(_body)));
      }

      // Timeout ve cancel desteği
      Future<HttpClientResponse> responseFuture = request.close();
      if (_timeout != null) {
        responseFuture = responseFuture.timeout(_timeout!);
      }
      if (_cancelToken != null && _cancelToken!.isCancelled) {
        throw CancelledException();
      }

      final response = await responseFuture;
      final responseBody = await response.transform(utf8.decoder).join();

      // Interceptor: onResponse
      final resOptions = ResponseOptions(
        statusCode: response.statusCode,
        body: responseBody,
        uri: uri,
        headers: {},
      );
      for (final interceptor in interceptors) {
        await interceptor.onResponse(resOptions);
      }

      // Hata yönetimi
      if (response.statusCode >= 400) {
        final error = RequestError(
          response.reasonPhrase ?? "HTTP ${response.statusCode}",
          options,
          statusCode: response.statusCode,
        );
        for (final interceptor in interceptors) {
          await interceptor.onError(error);
        }
        if (error.shouldRetry && error.retryToken != null && retryCount < 1) {
          // Token refresh sonrası tekrar dene
          _headers[HttpHeaders.authorizationHeader] = 'Bearer ${error.retryToken}';
          return await _request<T>(
            method,
            fromJson: fromJson,
            expectJsonArray: expectJsonArray,
            useCache: useCache,
            retryCount: retryCount + 1,
          );
        }
        if (response.statusCode == 401) throw UnauthorizedException();
        if (response.statusCode == 408) throw TimeoutException();
        if (response.statusCode == 500) throw ServerException();
        throw NetworkException("HTTP ${response.statusCode}");
      }

      // Body parse
      dynamic jsonData;
      try {
        jsonData = json.decode(responseBody);
      } catch (_) {
        jsonData = responseBody;
      }

      T? data;
      if (fromJson != null && jsonData != null) {
        if (expectJsonArray && jsonData is List) {
          data = (jsonData as List)
              .map((e) => fromJson(e as Map<String, dynamic>))
              .toList() as T;
        } else if (jsonData is Map<String, dynamic>) {
          data = fromJson(jsonData);
        }
      } else {
        data = jsonData;
      }

      final result = ResponseModel<T>(
        data: data,
        error: false,
        message: 'Success',
        statusCode: response.statusCode,
      );

      // Cache'e kaydet
      if (useCache && cacheManager != null) {
        cacheManager!.set(uri.toString(), result);
      }

      _reset();
      return result;
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException();
    } on CancelledException {
      throw CancelledException();
    } catch (e) {
      throw NetworkException(e.toString());
    } finally {
      _reset();
    }
  }

  String _buildUrl() {
    String url = (baseUrl ?? "") + (_path ?? "");
    if (_pathParams != null && _pathParams!.isNotEmpty) {
      _pathParams!.forEach((k, v) {
        url = url.replaceAll('{$k}', v.toString());
      });
    }
    return url;
  }
}
