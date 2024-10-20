class ResponseModel<T> {
  final T? data;
  final bool? error;
  final String? message;

  ResponseModel({this.data, this.error, this.message});

  // JSON'dan model'e dönüştüren fabrika fonksiyonu
  factory ResponseModel.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? fromJson,
  }) {
    // Eğer JSON'da 'data' anahtarı yoksa, veriyi doğrudan döndüreceğiz
    final responseData = json.containsKey('data') ? json['data'] : json;

    return ResponseModel<T>(
      data: fromJson != null ? fromJson(responseData) : responseData as T?,
      error: json['error'] as bool?,
      message: json['message'] as String?,
    );
  }

  // Model'den JSON'a dönüştüren fonksiyon
  Map<String, dynamic> toJson({
    Map<String, dynamic> Function(T)? toJson,
  }) {
    return {
      if (data != null) 'data': toJson != null ? toJson(data!) : data,
      if (error != null) 'error': error,
      if (message != null) 'message': message,
    };
  }
}
