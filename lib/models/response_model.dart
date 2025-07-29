class ResponseModel<T> {
  final T? data;
  final bool error;
  final String? message;
  final int? statusCode;

  ResponseModel({
    this.data,
    this.error = false,
    this.message,
    this.statusCode,
  });

  factory ResponseModel.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? fromJson,
  }) {
    return ResponseModel<T>(
      data: fromJson != null && json['data'] != null ? fromJson(json['data']) : json['data'],
      error: json['error'] ?? false,
      message: json['message'],
      statusCode: json['statusCode'],
    );
  }
}
