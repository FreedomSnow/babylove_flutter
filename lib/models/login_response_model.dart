import 'user_model.dart';
import 'family_model.dart';
import 'care_receiver_model.dart';

/// 登录响应数据模型
class LoginResponseData {
  final String token;
  final User user;
  final bool isNewUser;
  final Family? lastFamily;
  final CareReceiver? lastCareReceiver;

  LoginResponseData({
    required this.token,
    required this.user,
    required this.isNewUser,
    this.lastFamily,
    this.lastCareReceiver,
  });

  /// 从 JSON 创建实例
  factory LoginResponseData.fromJson(Map<String, dynamic> json) {
    return LoginResponseData(
      token: json['token'] as String? ?? '',
      user: User.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      isNewUser: json['isNewUser'] as bool? ?? false,
      lastFamily: json['last_family'] != null
          ? Family.fromJson(json['last_family'] as Map<String, dynamic>)
          : null,
      lastCareReceiver: json['last_care_receiver'] != null
          ? CareReceiver.fromJson(
              json['last_care_receiver'] as Map<String, dynamic>)
          : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'isNewUser': isNewUser,
      'last_family': lastFamily?.toJson(),
      'last_care_receiver': lastCareReceiver?.toJson(),
    };
  }

  @override
  String toString() {
    return 'LoginResponseData(token: $token, user: $user, isNewUser: $isNewUser)';
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
    return {
      'phone': phone,
      'code': code,
      'nickname': nickname,
    };
  }
}

/// 发送验证码请求参数
class SendSmsRequest {
  final String phone;

  SendSmsRequest({
    required this.phone,
  });

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
    };
  }
}

/// 发送验证码响应数据
class SendSmsResponseData {
  final String? code;
  final String? description;

  SendSmsResponseData({
    this.code,
    this.description,
  });

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
