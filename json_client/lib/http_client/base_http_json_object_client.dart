part of 'http_client.dart';

class BaseHttpJsonObjectClient {
  static String tag = '';
  final String baseUrl;
  final BaseHttpJsonObjectClientOptions options;
  final Map<String, dynamic> Function(String data, Response? response)?
  onTransformRawData;
  final int Function(Map<String, dynamic> data, Response? response)?
  onStatusCodeTransform;

  Dio? _client;

  Dio get client => _client ??= Dio(
    BaseOptions(
      connectTimeout: options.connectTimeout,
      receiveTimeout: options.receiveTimeout,
      sendTimeout: options.sendTimeout,
      responseType: options.responseType,
    ),
  );

  BaseHttpJsonObjectClient({
    required this.baseUrl,
    required this.options,
    this.onTransformRawData,
    this.onStatusCodeTransform,
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

      final statusCode = response.statusCode ?? 0;
      Logger.shared.log(
        'status code: $statusCode',
        tag: tag,
        correlationId: correlationId,
      );
      if (response.data != null) {
        Logger.shared.log(
          'res: ${response.data}',
          tag: tag,
          correlationId: correlationId,
        );

        if (200 <= statusCode && statusCode < 300) {
          return ApiResponse<Res, ErrorRes>(
            code: statusCode,
            response: convertSuccess(response.data ?? {}),
          );
        } else {
          return ApiResponse<Res, ErrorRes>(
            code: statusCode,
            errorResponse: convertError(response.data as Map<String, dynamic>),
          );
        }
      }
    } on DioException catch (e) {
      log('$correlationId    exception: ${e.toString()}');
      print(e);
      if (e.response != null && e.response?.data != null) {
        final res = onTransformRawData!.call(e.response!.data, e.response);

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
          errorResponse: convertError(res),
        );
      } else {
        return ApiResponse<Res, ErrorRes>(code: -1, exception: e);
      }
    } on Exception catch (e, _) {
      log('$correlationId    exception: ${e.toString()}');
      return ApiResponse<Res, ErrorRes>(code: -1, exception: e);
    }

    log('$correlationId    error: Unexpected Error');
    return ApiResponse<Res, ErrorRes>(
      code: -1,
      exception: Exception('Unexpected Error'),
    );
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
        ' with data 1: ${req.toJson().toString()}',
        tag: tag,
        correlationId: correlationId,
      );
    } else {
      Logger.shared.log(
        ' with data 2: ${req?.toString()}',
        tag: tag,
        correlationId: correlationId,
      );
    }
    Logger.shared.log(
      ' method: ${method.toString()}',
      tag: tag,
      correlationId: correlationId,
    );
    if (method == ApiMethod.post) {
      return _post(path: newPath, headers: headers, req: req);
    } else if (method == ApiMethod.put) {
      return _put(path: newPath, headers: headers, req: req);
    } else if (method == ApiMethod.delete) {
      return _delete(path: newPath, headers: headers, req: req);
    }
    if (req is BaseJson) {
      return _get(path: newPath, headers: headers, req: req.toJson());
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
        options: Options(headers: headers),
      ),
    );
  }

  Future<Response<Map<String, dynamic>>> _post<Data, Res, ErrorRes>({
    required String path,
    Map<String, dynamic>? headers,
    Data? req,
  }) async {
    final res = await client.post<String>(
      baseUrl + path,
      data: req,
      options: Options(headers: headers),
    );
    return convertRawResponse(res);
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
        options: Options(headers: headers),
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
        options: Options(headers: headers),
      ),
    );
  }

  Response<Map<String, dynamic>> convertRawResponse(Response<String> res) {
    final data =
        onTransformRawData?.call(res.data ?? '', res) ??
        json.decode(res.data ?? '{}');
    return Response(
      requestOptions: res.requestOptions,
      statusCode: onStatusCodeTransform?.call(data, res) ?? res.statusCode,
      statusMessage: res.statusMessage,
      isRedirect: res.isRedirect,
      redirects: res.redirects,
      extra: res.extra,
      headers: res.headers,
      data: data,
    );
  }
}
