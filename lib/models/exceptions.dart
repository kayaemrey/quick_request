class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = "Network error"]);
  @override
  String toString() => "NetworkException: $message";
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = "Unauthorized"]);
  @override
  String toString() => "UnauthorizedException: $message";
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException([this.message = "Timeout"]);
  @override
  String toString() => "TimeoutException: $message";
}

class CancelledException implements Exception {
  final String message;
  CancelledException([this.message = "Request cancelled"]);
  @override
  String toString() => "CancelledException: $message";
}

class ServerException implements Exception {
  final String message;
  ServerException([this.message = "Server error"]);
  @override
  String toString() => "ServerException: $message";
}
