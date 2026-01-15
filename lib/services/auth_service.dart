import 'package:babylove_flutter/core/network/network.dart';
import 'package:babylove_flutter/models/login_response_model.dart';
import 'package:babylove_flutter/services/storage_service.dart';
import 'package:flutter/widgets.dart';

/// 认证 API 服务
class AuthService {
  final HttpClient _httpClient = HttpClient();
  final StorageService _storageService = StorageService();

  /// 发送短信验证码
  ///
  /// 参数：
  /// - [phone] 手机号
  ///
  /// 返回：验证码发送结果（开发环境会返回验证码）
  Future<ApiResponseWithStringCode<SendSmsResponseData>> sendSmsCode({
    required String phone,
  }) async {
    try {
      final request = SendSmsRequest(phone: phone);

      final response = await _httpClient
          .postWithStringCode<SendSmsResponseData>(
            '/api/auth/sms/send',
            data: request.toJson(),
            fromJson: (json) =>
                SendSmsResponseData.fromJson(json as Map<String, dynamic>),
          );
      debugPrint('sendSmsCode response: $response');

      return response;
    } catch (e) {
      // 重新抛出异常
      rethrow;
    }
  }

  /// 短信登录
  ///
  /// 参数：
  /// - [phone] 手机号
  /// - [code] 短信验证码
  /// - [nickname] 昵称
  ///
  /// 返回：登录响应数据，包含 token、用户信息等
  Future<ApiResponseWithStringCode<LoginResponseData>> loginWithSms({
    required String phone,
    required String code,
    required String nickname,
  }) async {
    try {
      final request = LoginRequest(
        phone: phone,
        code: code,
        nickname: nickname,
      );

      final response = await _httpClient.postWithStringCode<LoginResponseData>(
        '/api/auth/login/sms',
        data: request.toJson(),
        fromJson: (json) =>
            LoginResponseData.fromJson(json as Map<String, dynamic>),
      );

      // 如果登录成功，保存 token
      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        final accessToken = data.accessToken.isNotEmpty ? data.accessToken : data.token;
        final refreshToken = data.refreshToken;
        _httpClient.setToken(accessToken);
        await _storageService.saveAccessToken(accessToken);
        await _storageService.saveRefreshToken(refreshToken);
      }

      return response;
    } catch (e) {
      // 重新抛出异常
      debugPrint('loginWithSms error: $e');
      rethrow;
    }
  }

  /// 退出登录
  Future<ApiResponseWithStringCode<void>> logout() async {
    try {
      // 调用后端的退出登录接口
      final response = await _httpClient.postWithStringCode<void>(
        '/api/auth/logout',
      );

      // 清除本地 token
      _httpClient.clearToken();
      await _storageService.clearTokens();

      return response;
    } catch (e) {
      // 即使请求失败，也清除本地 token
      _httpClient.clearToken();
      await _storageService.clearTokens();
      rethrow;
    }
  }

  /// 刷新 Token
  ///
  /// 参数：
  /// - [refreshToken] 刷新令牌
  ///
  /// 返回：新的登录响应数据（包含新的 token）
  Future<ApiResponseWithStringCode<RefreshTokenResponseData>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final request = {'refresh_token': refreshToken};

      final response = await _httpClient.postWithStringCode<RefreshTokenResponseData>(
        '/api/auth/refresh',
        data: request,
        fromJson: (json) => RefreshTokenResponseData.fromJson(json as Map<String, dynamic>),
      );

      // 如果刷新成功，更新并保存新的 token
      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        final accessToken = data.accessToken.isNotEmpty ? data.accessToken : data.token;
        final newRefreshToken = data.refreshToken;
        _httpClient.setToken(accessToken);
        await _storageService.saveAccessToken(accessToken);
        if (newRefreshToken.isNotEmpty) {
          await _storageService.saveRefreshToken(newRefreshToken);
        }
      }

      return response;
    } catch (e) {
      debugPrint('refreshToken error: $e');
      rethrow;
    }
  }

  /// 检查是否已登录（是否有 token）
  bool isLoggedIn() {
    final token = _httpClient.getToken();
    return token != null && token.isNotEmpty;
  }

  /// 获取当前的 token
  String? getToken() {
    return _httpClient.getToken();
  }

  /// 设置 token（用于从本地存储恢复登录状态）
  void setToken(String token) {
    _httpClient.setToken(token);
  }

  /// 提交意见反馈
  ///
  /// 参数：
  /// - [contact] 联系方式（邮箱、手机号等）
  /// - [content] 反馈内容
  ///
  /// 返回：提交结果
  Future<ApiResponseWithStringCode<void>> submitFeedback({
    required String contact,
    required String content,
  }) async {
    try {
      final request = {'contact': contact, 'content': content};

      final response = await _httpClient.postWithStringCode<void>(
        '/api/new-feedback',
        data: request,
      );

      return response;
    } catch (e) {
      // 重新抛出异常
      rethrow;
    }
  }

  /// 获取当前用户信息（me）
  ///
  /// GET /api/auth/me
  /// 返回结构（示例）见接口文档，使用 `LoginResponseData` 解析 `data` 字段
  Future<ApiResponseWithStringCode<LoginResponseData>> getMe() async {
    try {
      final response = await _httpClient.getWithStringCode<LoginResponseData>(
        '/api/auth/me',
        fromJson: (json) => LoginResponseData.fromJson(json as Map<String, dynamic>),
      );

      debugPrint('getMe response: $response');

      return response;
    } catch (e) {
      debugPrint('getMe error: $e');
      rethrow;
    }
  }
}
