import 'dart:convert';
import 'dart:developer';

import 'package:common_sdk/common_sdk.dart';
import 'package:dio/dio.dart';

import 'api_response.dart';
import 'base_json.dart';
import 'enums/api_method.dart';

class BaseHttpJsonObjectClientOptions {
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  BaseHttpJsonObjectClientOptions({
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
  });
}

class BaseHttpJsonObjectClient {
  static String tag = '';
  final String baseUrl;
  final BaseHttpJsonObjectClientOptions options;
  final Map<String, dynamic> Function(String s)? onTransformRawData;

  Dio? _client;

  Dio get client => _client ??= Dio(
        BaseOptions(
          connectTimeout: options.connectTimeout,
          receiveTimeout: options.receiveTimeout,
          sendTimeout: options.sendTimeout,
        ),
      );

  BaseHttpJsonObjectClient({
    required this.baseUrl,
    required this.options,
    this.onTransformRawData,
  });

  Future<ApiResponse<Res, ErrorRes>> call<Data, Res, ErrorRes>({
    required String path,
    required ApiMethod method,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? headers,
    Data? req,
    required Res Function(Map<String, dynamic> data) convertSuccess,
    required ErrorRes Function(Map<String, dynamic> data) convertError,
    String? correlationId,
  }) async {
    BaseOptions();

    try {
      final response = await _callMethod<Data, Res, ErrorRes>(
        path: path,
        method: method,
        headers: headers,
        pathParams: pathParams,
        req: req,
        correlationId: correlationId,
      );

      if (response.data != null) {
        final statusCode = response.statusCode ?? 0;
        Logger.shared.log(
          'status code: $statusCode',
          tag: tag,
          correlationId: correlationId,
        );
        Logger.shared.log(
          'res: ${response.data}',
          tag: tag,
          correlationId: correlationId,
        );
        if (200 <= statusCode && statusCode < 300) {
          if (response.data?["isSuccess"] ?? true) {
            return ApiResponse<Res, ErrorRes>(
                code: statusCode,
                response: convertSuccess(response.data ?? {}));
          } else {
            return ApiResponse<Res, ErrorRes>(
                code: 400,
                errorResponse:
                    convertError(response.data as Map<String, dynamic>));
          }
        } else {
          if (statusCode > 0) {
            return ApiResponse<Res, ErrorRes>(
                code: statusCode,
                errorResponse:
                    convertError(response.data as Map<String, dynamic>));
          }
        }
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final res = onTransformRawData!.call(e.response!.data);

        Logger.shared.log(
          'error status code: ${e.response?.statusCode ?? -1}',
          tag: tag,
          correlationId: correlationId,
        );
        Logger.shared.log(
          'error res: ${e.response?.data}',
          tag: tag,
          correlationId: correlationId,
        );
        return ApiResponse<Res, ErrorRes>(
            code: e.response?.statusCode ?? -1,
            errorResponse: convertError(res));
      } else {
        return ApiResponse<Res, ErrorRes>(
            code: -1, exception: Exception('Invalid Error Response'));
      }
    } on Exception catch (e, _) {
      log('$correlationId    exception: ${e.toString()}');
      return ApiResponse<Res, ErrorRes>(code: -1, exception: e);
    }

    log('$correlationId    error: Unexpected Error');
    return ApiResponse<Res, ErrorRes>(
        code: -1, exception: Exception('Unexpected Error'));
  }

  Future<Response<Map<String, dynamic>>> _callMethod<Data, Res, ErrorRes>({
    required String path,
    required ApiMethod method,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? pathParams,
    Data? req,
    String? correlationId,
  }) {
    var newPath = path;
    if (pathParams != null && headers != null) {
      for (final key in headers.keys) {
        newPath = newPath.replaceAll('{$key}', headers[key]!);
      }
    }

    Logger.shared.log(
      'calling: ${baseUrl + newPath}',
      tag: tag,
      correlationId: correlationId,
    );
    Logger.shared.log(
      'with base url: $baseUrl',
      tag: tag,
      correlationId: correlationId,
    );
    Logger.shared.log(
      'with path: $newPath',
      tag: tag,
      correlationId: correlationId,
    );
    Logger.shared.log(
      ' with headers: ${headers.toString()}',
      tag: tag,
      correlationId: correlationId,
    );

    if (req is BaseJson) {
      Logger.shared.log(
        ' with data: ${req.toJson().toString()}',
        tag: tag,
        correlationId: correlationId,
      );
    } else {
      Logger.shared.log(
        ' with data: ${req?.toString()}',
        tag: tag,
        correlationId: correlationId,
      );
    }

    if (method == ApiMethod.post) {
      return _post(
        path: newPath,
        headers: headers,
        req: req,
      );
    } else if (method == ApiMethod.put) {
      return _put(
        path: newPath,
        headers: headers,
        req: req,
      );
    } else if (method == ApiMethod.delete) {
      return _delete(
        path: newPath,
        headers: headers,
        req: req,
      );
    }
    if (req is BaseJson) {
      return _get(
        path: newPath,
        headers: headers,
        req: req.toJson(),
      );
    }
    throw Exception("Request Data Must Extend BaseJson Class for Get Method !");
  }

  Future<Response<Map<String, dynamic>>>
      _get<Data extends BaseJson, Res, ErrorRes>({
    required String path,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? req,
  }) async {
    return convertRawResponse(
      await client.get<String>(
        baseUrl + path,
        queryParameters: req ?? {},
        options: Options(
          headers: headers,
        ),
      ),
    );
  }

  Future<Response<Map<String, dynamic>>> _post<Data, Res, ErrorRes>({
    required String path,
    Map<String, dynamic>? headers,
    Data? req,
  }) async {
    return convertRawResponse(
      await client.post<String>(
        baseUrl + path,
        data: req,
        options: Options(
          headers: headers,
        ),
      ),
    );
  }

  Future<Response<Map<String, dynamic>>> _put<Data, Res, ErrorRes>({
    required String path,
    Map<String, dynamic>? headers,
    Data? req,
  }) async {
    return convertRawResponse(
      await client.put<String>(
        baseUrl + path,
        data: req,
        options: Options(
          headers: headers,
        ),
      ),
    );
  }

  Future<Response<Map<String, dynamic>>> _delete<Data, Res, ErrorRes>({
    required String path,
    Data? req,
    Map<String, dynamic>? headers,
  }) async {
    return convertRawResponse(
      await client.delete<String>(
        baseUrl + path,
        queryParameters: (req is BaseJson) ? req.toJson() : {},
        options: Options(
          headers: headers,
        ),
      ),
    );
  }

  Response<Map<String, dynamic>> convertRawResponse(Response<String> res) {
    return Response(
      requestOptions: res.requestOptions,
      statusCode: res.statusCode,
      statusMessage: res.statusMessage,
      isRedirect: res.isRedirect,
      redirects: res.redirects,
      extra: res.extra,
      headers: res.headers,
      data: onTransformRawData?.call(res.data ?? '') ??
          json.decode(res.data ?? '{}'),
    );
  }
}
