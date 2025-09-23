part of 'http_client.dart';
class ApiResponse<R, ER> {
  final int code;
  final R? response;
  final ER? errorResponse;
  final Exception? exception;

  bool get isSuccess => 200 <= code && code < 300;
  bool get isError => 0 < code && !isSuccess;
  bool get isException => 0 == code;

  ApiResponse({
    required this.code,
    this.response,
    this.errorResponse,
    this.exception,
  });
}
