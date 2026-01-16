import 'package:dio/dio.dart';

/// 网络异常类
class NetworkException implements Exception {
  final String message;
  final int? code;
  final DioExceptionType? type;

  NetworkException({
    required this.message,
    this.code,
    this.type,
  });

  factory NetworkException.fromDioException(DioException error) {
    String message = '网络请求失败';
    int? code;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = '连接超时，请检查网络设置';
        break;
      case DioExceptionType.sendTimeout:
        message = '发送超时，请检查网络设置';
        break;
      case DioExceptionType.receiveTimeout:
        message = '接收超时，请检查网络设置';
        break;
      case DioExceptionType.badResponse:
        code = error.response?.statusCode;
        // 优先返回服务端的错误信息（包括字符串或 JSON message 字段），否则使用状态码提示
        final data = error.response?.data;
        String? serverMessage;
        if (data is Map<String, dynamic>) {
          serverMessage = data['message']?.toString() ?? data['msg']?.toString() ?? data['error']?.toString();
        } else if (data is String) {
          serverMessage = data.trim();
        }

        if (serverMessage != null && serverMessage.isNotEmpty) {
          // 避免过长的 HTML 或文本占满 UI，截断到 200 字符
          if (serverMessage.length > 200) {
            serverMessage = serverMessage.substring(0, 200) + '...';
          }
          message = serverMessage;
        } else {
          message = _handleStatusCode(code);
        }
        break;
      case DioExceptionType.cancel:
        message = '请求已取消';
        break;
      case DioExceptionType.unknown:
        if (error.error != null) {
          message = '网络连接失败，请检查网络设置';
        } else {
          message = '未知错误';
        }
        break;
      default:
        message = '网络请求失败';
    }

    return NetworkException(
      message: message,
      code: code,
      type: error.type,
    );
  }

  static String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请重新登录';
      case 403:
        return '拒绝访问';
      case 404:
        return '请求的资源不存在';
      case 405:
        return '请求方法不允许';
      case 408:
        return '请求超时';
      case 500:
        return '服务器内部错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务不可用';
      case 504:
        return '网关超时';
      default:
        return '网络请求失败($statusCode)';
    }
  }

  @override
  String toString() {
    return message;
  }
}
