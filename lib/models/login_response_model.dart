import 'user_model.dart';
import 'family_model.dart';
import 'care_receiver_model.dart';

/// 登录响应数据模型
class LoginResponseData {
  final String accessToken;
  final String refreshToken;
  // 保留旧字段，内部与 accessToken 对齐，便于兼容旧调用方
  final String token;
  final User user;
  final bool isNewUser;
  final Family? lastFamily;
  final CareReceiver? lastCareReceiver;

  LoginResponseData({
    required this.accessToken,
    required this.refreshToken,
    required this.token,
    required this.user,
    required this.isNewUser,
    this.lastFamily,
    this.lastCareReceiver,
  });

  /// 从 JSON 创建实例
  factory LoginResponseData.fromJson(Map<String, dynamic> json) {
    final parsedAccessToken =
        (json['access_token'] as String?) ?? (json['token'] as String?) ?? '';
    return LoginResponseData(
      accessToken: parsedAccessToken,
      refreshToken: json['refresh_token'] as String? ?? '',
      // token 与 accessToken 对齐，避免旧代码拿到空值
      token: parsedAccessToken,
      user: User.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      isNewUser: json['isNewUser'] as bool? ?? false,
      lastFamily: json['last_family'] != null
          ? Family.fromJson(json['last_family'] as Map<String, dynamic>)
          : null,
      lastCareReceiver: json['last_care_receiver'] != null
          ? CareReceiver.fromJson(
              json['last_care_receiver'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token': token,
      'user': user.toJson(),
      'isNewUser': isNewUser,
      'last_family': lastFamily?.toJson(),
      'last_care_receiver': lastCareReceiver?.toJson(),
    };
  }

  @override
  String toString() {
    return 'LoginResponseData(accessToken: $accessToken, refreshToken: $refreshToken, user: $user, isNewUser: $isNewUser)';
  }
}

/// 刷新 Token 接口响应数据
class RefreshTokenResponseData {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final String token;

  RefreshTokenResponseData({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.token,
  });

  factory RefreshTokenResponseData.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponseData(
      accessToken: json['access_token'] as String? ?? json['token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? '',
      expiresIn: json['expires_in'] is int ? json['expires_in'] as int : int.tryParse('${json['expires_in']}') ?? 0,
      token: json['token'] as String? ?? json['access_token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'token': token,
    };
  }
}

/// 登录请求参数
class LoginRequest {
  final String phone;
  final String code;
  final String nickname;

  LoginRequest({
    required this.phone,
    required this.code,
    required this.nickname,
  });

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {'phone': phone, 'code': code, 'nickname': nickname};
  }
}

/// 发送验证码请求参数
class SendSmsRequest {
  final String phone;

  SendSmsRequest({required this.phone});

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {'phone': phone};
  }
}

/// 发送验证码响应数据
class SendSmsResponseData {
  final String? code;
  final String? description;

  SendSmsResponseData({this.code, this.description});

  /// 从 JSON 创建实例
  factory SendSmsResponseData.fromJson(Map<String, dynamic> json) {
    return SendSmsResponseData(
      code: json['code'] as String?,
      description: json['description'] as String?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      if (code != null) 'code': code,
      if (description != null) 'description': description,
    };
  }

  @override
  String toString() {
    return 'SendSmsResponseData(code: $code, description: $description)';
  }
}
