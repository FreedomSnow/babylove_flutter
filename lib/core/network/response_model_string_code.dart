/// 带字符串状态码的 API 响应模型（用于特殊接口）
/// 例如：code 为 "NO_ERROR" 表示成功
class ApiResponseWithStringCode<T> {
  /// 状态码（字符串类型）
  final String code;

  /// 响应消息
  final String? message;

  /// 响应数据
  final T? data;

  /// 是否成功
  bool get isSuccess => code == 'NO_ERROR';

  ApiResponseWithStringCode({
    required this.code,
    this.message,
    this.data,
  });

  /// 从 JSON 创建实例
  factory ApiResponseWithStringCode.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponseWithStringCode<T>(
      code: json['code'] as String? ?? '',
      message: json['message'] as String? ?? json['msg'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      if (message != null) 'message': message,
      'data': data,
    };
  }

  @override
  String toString() {
    return 'ApiResponseWithStringCode{code: $code, message: $message, data: $data}';
  }
}
