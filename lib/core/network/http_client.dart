import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'network_config.dart';
import 'network_exception.dart';
import 'response_model.dart';
import 'response_model_string_code.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

/// HTTP 客户端类 - 封装 Dio 实例
class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;

  late Dio _dio;
  final AuthInterceptor _authInterceptor = AuthInterceptor();

  HttpClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: NetworkConfig.baseUrl,
        connectTimeout: Duration(milliseconds: NetworkConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: NetworkConfig.receiveTimeout),
        sendTimeout: Duration(milliseconds: NetworkConfig.sendTimeout),
        headers: NetworkConfig.headers,
      ),
    );

    _initInterceptors();
  }

  /// 初始化拦截器
  void _initInterceptors() {
    // 添加认证拦截器
    _dio.interceptors.add(_authInterceptor);

    // 添加错误处理拦截器
    _dio.interceptors.add(ErrorInterceptor());

    // 添加重试拦截器
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: NetworkConfig.retryCount,
        retryDelays: List.generate(
          NetworkConfig.retryCount,
          (index) => Duration(milliseconds: NetworkConfig.retryDelay * (index + 1)),
        ),
      ),
    );

    // 添加日志拦截器（开发环境）
    if (NetworkConfig.enableLog) {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ));
      
      // 可选：使用自定义日志拦截器
      // _dio.interceptors.add(LoggingInterceptor());
    }
  }

  /// 获取 Dio 实例
  Dio get dio => _dio;

  /// 设置 Token
  void setToken(String? token) {
    _authInterceptor.setToken(token);
  }

  /// 获取 Token
  String? getToken() {
    return _authInterceptor.getToken();
  }

  /// 清除 Token
  void clearToken() {
    _authInterceptor.clearToken();
  }

  /// GET 请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST 请求
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT 请求
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE 请求
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH 请求
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 上传文件
  Future<ApiResponse<T>> upload<T>(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 下载文件
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    Options? options,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 处理响应
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic json)? fromJson,
  ) {
    if (response.data is Map<String, dynamic>) {
      return ApiResponse<T>.fromJson(
        response.data as Map<String, dynamic>,
        fromJson,
      );
    } else {
      // 如果响应不是标准格式，创建一个包装的响应
      return ApiResponse<T>(
        code: response.statusCode ?? 200,
        message: 'Success',
        data: fromJson != null ? fromJson(response.data) : response.data as T?,
      );
    }
  }

  /// 处理错误
  NetworkException _handleError(DioException error) {
    if (error.error is NetworkException) {
      return error.error as NetworkException;
    }
    return NetworkException.fromDioException(error);
  }

  /// 取消所有请求
  void cancelRequests({CancelToken? cancelToken}) {
    cancelToken?.cancel('Request cancelled');
  }

  /// POST 请求（支持字符串类型的 code）
  Future<ApiResponseWithStringCode<T>> postWithStringCode<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponseWithStringCode<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET 请求（支持字符串类型的 code）
  Future<ApiResponseWithStringCode<T>> getWithStringCode<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponseWithStringCode<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT 请求（支持字符串类型的 code）
  Future<ApiResponseWithStringCode<T>> putWithStringCode<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponseWithStringCode<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE 请求（支持字符串类型的 code）
  Future<ApiResponseWithStringCode<T>> deleteWithStringCode<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponseWithStringCode<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 处理字符串 code 的响应
  ApiResponseWithStringCode<T> _handleResponseWithStringCode<T>(
    Response response,
    T Function(dynamic json)? fromJson,
  ) {
    if (response.data is Map<String, dynamic>) {
      return ApiResponseWithStringCode<T>.fromJson(
        response.data as Map<String, dynamic>,
        fromJson,
      );
    } else {
      // 如果响应不是标准格式，创建一个包装的响应
      return ApiResponseWithStringCode<T>(
        code: '${response.statusCode ?? 200}',
        message: 'Success',
        data: fromJson != null ? fromJson(response.data) : response.data as T?,
      );
    }
  }
}
