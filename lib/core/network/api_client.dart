import 'package:dio/dio.dart';

import '../session/app_session.dart';

/// 封装 Dio 单例，提供统一的基础配置。
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        responseType: ResponseType.json,
        contentType: Headers.jsonContentType,
        headers: {
          'Accept': 'application/json',
        },
      ),
    )..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final token = AppSession.instance.currentUser.value?.token;
            if (token != null && token.isNotEmpty) {
              options.headers['Ops-Token'] = token;
            } else {
              options.headers.remove('Ops-Token');
            }
            return handler.next(options);
          },
        ),
      );
  }

  static final ApiClient _instance = ApiClient._internal();

  static const String _baseUrl = 'https://demo-ops.ccdental.cn/backend';

  late final Dio _dio;

  factory ApiClient() => _instance;

  Dio get dio => _dio;

  /// 统一处理后端返回结构，尽量保证调用方拿到的是 Map 数据。
  Future<Map<String, dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final response = await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return _unwrapResponse(response.data);
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final response = await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
    return _unwrapResponse(response.data);
  }

  Map<String, dynamic> _unwrapResponse(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw Exception('返回格式不正确');
    }
    final nestedData = data['data'];
    if (nestedData is Map<String, dynamic>) {
      return nestedData;
    }
    return data;
  }
}

