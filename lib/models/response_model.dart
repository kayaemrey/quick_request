class ResponseModel<T> {
  final T? data;
  final bool error;
  final String message;

  ResponseModel({this.data, required this.error, required this.message});

  factory ResponseModel.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return ResponseModel<T>(
      data: fromJson(json['data']),
      error: json['error'] ?? false,
      message: json['message'] ?? "",
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJson) {
    return {
      // ignore: null_check_on_nullable_type_parameter
      'data': toJson(data!),
      'error': error,
      'message': message,
    };
  }
}
