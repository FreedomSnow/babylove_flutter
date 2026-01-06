/// 统一的 API 响应模型
class ApiResponse<T> {
  /// 状态码
  final int code;

  /// 响应消息
  final String message;

  /// 响应数据
  final T? data;

  /// 是否成功
  bool get isSuccess => code == 200 || code == 0;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  /// 从 JSON 创建实例
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? json['msg'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data,
    };
  }

  @override
  String toString() {
    return 'ApiResponse{code: $code, message: $message, data: $data}';
  }
}

/// 分页响应模型
class PageResponse<T> {
  /// 当前页码
  final int page;

  /// 每页数量
  final int pageSize;

  /// 总数
  final int total;

  /// 总页数
  final int totalPages;

  /// 数据列表
  final List<T> list;

  /// 是否有下一页
  bool get hasMore => page < totalPages;

  PageResponse({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
    required this.list,
  });

  /// 从 JSON 创建实例
  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return PageResponse<T>(
      page: json['page'] as int? ?? json['current'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? json['size'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? json['pages'] as int? ?? 0,
      list: (json['list'] as List<dynamic>?)
              ?.map((item) => fromJsonT(item))
              .toList() ??
          (json['records'] as List<dynamic>?)
              ?.map((item) => fromJsonT(item))
              .toList() ??
          [],
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'pageSize': pageSize,
      'total': total,
      'totalPages': totalPages,
      'list': list,
    };
  }
}
