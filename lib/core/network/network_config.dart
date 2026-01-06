/// 网络请求配置类
class NetworkConfig {
  /// API 基础 URL
  static const String baseUrl = 'https://babycare-dev.dujiepeng.top';

  /// 连接超时时间（毫秒）
  static const int connectTimeout = 30000;

  /// 接收超时时间（毫秒）
  static const int receiveTimeout = 30000;

  /// 发送超时时间（毫秒）
  static const int sendTimeout = 30000;

  /// 是否启用日志
  static const bool enableLog = true;

  /// 重试次数
  static const int retryCount = 3;

  /// 重试延迟（毫秒）
  static const int retryDelay = 1000;

  /// 请求头
  static Map<String, dynamic> get headers => {
        'Content-Type': 'application/json',
        'accept': 'application/json',
      };
}
