import 'dart:io';

abstract class QuickRequestInterceptor {
  /// İstek gönderilmeden hemen önce çalışır.
  Future<void> onRequest(HttpClientRequest request) async {}

  /// Yanıt geldikten hemen sonra çalışır.
  Future<void> onResponse(HttpClientResponse response) async {}

  /// Hata oluşursa çalışır.
  Future<void> onError(Object error) async {}
}
