import 'package:dio/dio.dart';
import 'package:babylove_flutter/core/network/network.dart';

/// 网络请求使用示例
class NetworkExample {
  final HttpClient _httpClient = HttpClient();

  /// 示例 1: 简单的 GET 请求
  Future<void> getExample() async {
    try {
      final response = await _httpClient.get(
        '/api/user/profile',
        queryParameters: {'userId': '123'},
      );

      if (response.isSuccess) {
        print('请求成功: ${response.data}');
      } else {
        print('请求失败: ${response.message}');
      }
    } on NetworkException catch (e) {
      print('网络错误: ${e.message}');
    }
  }

  /// 示例 2: POST 请求并解析为模型
  Future<void> postWithModelExample() async {
    try {
      // 假设有一个 User 模型
      final response = await _httpClient.post<Map<String, dynamic>>(
        '/api/user/login',
        data: {
          'username': 'test@example.com',
          'password': '123456',
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        final userData = response.data!;
        print('登录成功: $userData');
        
        // 保存 token
        final token = userData['token'] as String?;
        if (token != null) {
          _httpClient.setToken(token);
        }
      }
    } on NetworkException catch (e) {
      print('登录失败: ${e.message}');
    }
  }

  /// 示例 3: 带认证的请求
  Future<void> authenticatedRequestExample() async {
    // 先设置 token
    _httpClient.setToken('your_access_token_here');

    try {
      final response = await _httpClient.get('/api/user/info');

      if (response.isSuccess) {
        print('用户信息: ${response.data}');
      }
    } on NetworkException catch (e) {
      print('获取用户信息失败: ${e.message}');
    }
  }

  /// 示例 4: 上传文件
  Future<void> uploadFileExample(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: 'avatar.jpg',
        ),
        'userId': '123',
      });

      final response = await _httpClient.upload(
        '/api/upload/avatar',
        formData: formData,
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100).toStringAsFixed(1);
          print('上传进度: $progress%');
        },
      );

      if (response.isSuccess) {
        print('上传成功: ${response.data}');
      }
    } on NetworkException catch (e) {
      print('上传失败: ${e.message}');
    }
  }

  /// 示例 5: 下载文件
  Future<void> downloadFileExample(String url, String savePath) async {
    try {
      await _httpClient.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(1);
            print('下载进度: $progress%');
          }
        },
      );
      print('下载完成: $savePath');
    } on NetworkException catch (e) {
      print('下载失败: ${e.message}');
    }
  }

  /// 示例 6: 可取消的请求
  Future<void> cancellableRequestExample() async {
    final cancelToken = CancelToken();

    // 5秒后取消请求
    Future.delayed(Duration(seconds: 5), () {
      _httpClient.cancelRequests(cancelToken: cancelToken);
    });

    try {
      final response = await _httpClient.get(
        '/api/long-running-task',
        cancelToken: cancelToken,
      );

      if (response.isSuccess) {
        print('请求完成: ${response.data}');
      }
    } on NetworkException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        print('请求已取消');
      } else {
        print('请求失败: ${e.message}');
      }
    }
  }

  /// 示例 7: 处理分页数据
  Future<void> paginationExample() async {
    try {
      final response = await _httpClient.get(
        '/api/posts',
        queryParameters: {
          'page': 1,
          'pageSize': 20,
        },
      );

      if (response.isSuccess && response.data != null) {
        // 假设后端返回的数据格式符合 PageResponse
        final pageData = PageResponse<Map<String, dynamic>>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => json as Map<String, dynamic>,
        );

        print('当前页: ${pageData.page}');
        print('总数: ${pageData.total}');
        print('是否有更多: ${pageData.hasMore}');
        print('数据列表: ${pageData.list}');
      }
    } on NetworkException catch (e) {
      print('获取列表失败: ${e.message}');
    }
  }
}
