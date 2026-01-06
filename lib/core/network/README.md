# 网络请求模块

## 概述

这是一个基于 Dio 封装的通用网络请求模块，提供了完整的 HTTP 请求功能，包括请求拦截、错误处理、认证管理、日志记录等。

## 功能特性

- ✅ 支持 GET、POST、PUT、DELETE、PATCH 等常用请求方法
- ✅ 统一的响应数据格式
- ✅ 完善的错误处理机制
- ✅ Token 认证管理
- ✅ 请求日志记录
- ✅ 自动重试机制
- ✅ 文件上传和下载
- ✅ 请求取消功能
- ✅ 分页数据处理

## 文件结构

```
lib/core/network/
├── network.dart              # 统一导出文件
├── http_client.dart          # HTTP 客户端封装
├── network_config.dart       # 网络配置
├── network_exception.dart    # 异常处理
├── response_model.dart       # 响应模型
├── example.dart             # 使用示例
└── interceptors/            # 拦截器目录
    ├── auth_interceptor.dart      # 认证拦截器
    ├── error_interceptor.dart     # 错误拦截器
    └── logging_interceptor.dart   # 日志拦截器
```

## 使用方法

### 1. 配置基础 URL

编辑 `lib/core/network/network_config.dart`：

```dart
class NetworkConfig {
  static const String baseUrl = 'https://your-api-domain.com';
  // ... 其他配置
}
```

### 2. 基本使用

```dart
import 'package:babylove_flutter/core/network/network.dart';

// 创建客户端实例
final httpClient = HttpClient();

// GET 请求
try {
  final response = await httpClient.get('/api/user/profile');
  if (response.isSuccess) {
    print('数据: ${response.data}');
  }
} on NetworkException catch (e) {
  print('错误: ${e.message}');
}
```

### 3. 带参数的 POST 请求

```dart
final response = await httpClient.post(
  '/api/user/login',
  data: {
    'username': 'user@example.com',
    'password': '123456',
  },
);
```

### 4. 设置认证 Token

```dart
// 登录后设置 token
httpClient.setToken('your_access_token');

// 之后的请求会自动带上 Authorization header
final response = await httpClient.get('/api/protected/resource');

// 退出登录时清除 token
httpClient.clearToken();
```

### 5. 上传文件

```dart
final formData = FormData.fromMap({
  'file': await MultipartFile.fromFile(
    filePath,
    filename: 'photo.jpg',
  ),
  'description': '图片描述',
});

final response = await httpClient.upload(
  '/api/upload',
  formData: formData,
  onSendProgress: (sent, total) {
    print('进度: ${(sent / total * 100).toStringAsFixed(1)}%');
  },
);
```

### 6. 下载文件

```dart
await httpClient.download(
  '/api/files/document.pdf',
  '/path/to/save/document.pdf',
  onReceiveProgress: (received, total) {
    if (total != -1) {
      print('进度: ${(received / total * 100).toStringAsFixed(1)}%');
    }
  },
);
```

### 7. 取消请求

```dart
final cancelToken = CancelToken();

// 发起请求
httpClient.get('/api/data', cancelToken: cancelToken);

// 取消请求
httpClient.cancelRequests(cancelToken: cancelToken);
```

### 8. 处理分页数据

```dart
final response = await httpClient.get(
  '/api/posts',
  queryParameters: {'page': 1, 'pageSize': 20},
);

if (response.isSuccess && response.data != null) {
  final pageData = PageResponse<Post>.fromJson(
    response.data as Map<String, dynamic>,
    (json) => Post.fromJson(json),
  );
  
  print('总数: ${pageData.total}');
  print('是否有更多: ${pageData.hasMore}');
}
```

## API 响应格式

模块期望的标准响应格式：

```json
{
  "code": 200,
  "message": "success",
  "data": { ... }
}
```

对于分页数据：

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "page": 1,
    "pageSize": 20,
    "total": 100,
    "totalPages": 5,
    "list": [ ... ]
  }
}
```

## 错误处理

模块会自动将 Dio 异常转换为 `NetworkException`，并提供友好的错误消息：

- 连接超时
- 发送/接收超时
- HTTP 状态码错误（400、401、403、404、500 等）
- 网络连接失败
- 请求取消

## 配置说明

在 `network_config.dart` 中可以配置：

- `baseUrl`: API 基础 URL
- `connectTimeout`: 连接超时时间（默认 30 秒）
- `receiveTimeout`: 接收超时时间（默认 30 秒）
- `sendTimeout`: 发送超时时间（默认 30 秒）
- `enableLog`: 是否启用日志（默认 true）
- `retryCount`: 重试次数（默认 3 次）
- `retryDelay`: 重试延迟（默认 1 秒）

## 更多示例

查看 `lib/core/network/example.dart` 获取更多使用示例。

## 依赖包

- `dio`: HTTP 客户端
- `dio_smart_retry`: 智能重试
- `pretty_dio_logger`: 漂亮的日志输出

## 注意事项

1. 在生产环境中，建议关闭日志：设置 `NetworkConfig.enableLog = false`
2. 根据实际后端 API 格式调整 `ApiResponse` 和 `PageResponse` 的 JSON 解析逻辑
3. Token 存储建议配合 `shared_preferences` 或 `flutter_secure_storage` 实现持久化
4. 401 错误会自动清除 token，建议配合导航逻辑跳转到登录页
