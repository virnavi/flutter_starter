part of 'http_client.dart';

class BaseHttpJsonObjectClientOptions {
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final ResponseType responseType;

  BaseHttpJsonObjectClientOptions({
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.responseType = ResponseType.json,
  });
}
