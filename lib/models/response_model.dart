class ResponseModel<T> {
  final T? data;
  final bool? error;
  final String? message;

  ResponseModel({this.data, this.error, this.message});

  // JSON'dan model'e dönüştüren fabrika fonksiyonu
  factory ResponseModel.fromJson(
    Map<String, dynamic> json, {
    required T Function(dynamic) fromJson,
  }) {
    final responseData = json.containsKey('data') ? json['data'] : json;

    return ResponseModel<T>(
      data: fromJson(responseData),
      error: json['error'] as bool?,
      message: json['message'] as String?,
    );
  }

  // Model'den JSON'a dönüştüren fonksiyon
  Map<String, dynamic> toJson({
    required Map<String, dynamic> Function(T) toJson,
  }) {
    return {
      if (data != null) 'data': toJson(data!),
      if (error != null) 'error': error,
      if (message != null) 'message': message,
    };
  }
}
