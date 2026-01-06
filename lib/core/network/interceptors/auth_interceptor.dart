import 'package:dio/dio.dart';

/// 认证拦截器 - 用于添加认证 token
class AuthInterceptor extends Interceptor {
  String? _token;

  /// 设置 token
  void setToken(String? token) {
    _token = token;
  }

  /// 获取 token
  String? getToken() {
    return _token;
  }

  /// 清除 token
  void clearToken() {
    _token = null;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 如果有 token，添加到请求头
    if (_token != null && _token!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 如果是 401 错误，清除 token
    if (err.response?.statusCode == 401) {
      clearToken();
      // 这里可以触发跳转到登录页面的逻辑
      // 例如：使用 EventBus 发送登录过期事件
    }
    super.onError(err, handler);
  }
}
