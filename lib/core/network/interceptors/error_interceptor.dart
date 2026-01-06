import 'package:dio/dio.dart';
import '../network_exception.dart';

/// 错误处理拦截器
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 将 DioException 转换为 NetworkException
    final networkException = NetworkException.fromDioException(err);
    
    // 包装错误
    final wrappedError = DioException(
      requestOptions: err.requestOptions,
      error: networkException,
      type: err.type,
      response: err.response,
    );

    super.onError(wrappedError, handler);
  }
}
