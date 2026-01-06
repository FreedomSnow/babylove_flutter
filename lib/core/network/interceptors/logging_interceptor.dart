import 'package:dio/dio.dart';

/// 日志拦截器
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('========== 请求开始 ==========');
    print('请求方法: ${options.method}');
    print('请求路径: ${options.uri}');
    print('请求头: ${options.headers}');
    if (options.data != null) {
      print('请求参数: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      print('查询参数: ${options.queryParameters}');
    }
    print('========== 请求结束 ==========');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('========== 响应开始 ==========');
    print('响应码: ${response.statusCode}');
    print('响应数据: ${response.data}');
    print('========== 响应结束 ==========');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('========== 错误开始 ==========');
    print('错误类型: ${err.type}');
    print('错误消息: ${err.message}');
    print('错误响应: ${err.response?.data}');
    print('========== 错误结束 ==========');
    super.onError(err, handler);
  }
}
