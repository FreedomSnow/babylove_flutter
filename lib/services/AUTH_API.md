# 登录接口文档

## 接口信息

- **接口地址**: `/api/auth/login/sms`
- **请求方法**: `POST`
- **内容类型**: `application/json`

## 请求参数

```json
{
  "phone": "13800138000",
  "code": "123456",
  "nickname": "测试用户"
}
```

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| phone | string | 是 | 手机号码 |
| code | string | 是 | 短信验证码 |
| nickname | string | 是 | 用户昵称 |

## 响应数据

### 成功响应

```json
{
  "code": "NO_ERROR",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "1",
      "username": null,
      "phone": "13800138000",
      "nickname": "测试用户",
      "avatar": null,
      "gender": 0,
      "last_login_at": 1724284800000,
      "created_at": 1724284800000,
      "updated_at": 1724284800000
    },
    "isNewUser": true,
    "last_family": {
      "id": "1",
      "name": "我的家庭"
    },
    "last_care_receiver": {
      "id": "5",
      "name": "爷爷"
    }
  }
}
```

### 响应字段说明

| 字段名 | 类型 | 说明 |
|--------|------|------|
| code | string | 状态码，"NO_ERROR" 表示成功 |
| data | object | 响应数据对象 |
| data.token | string | JWT 认证令牌 |
| data.user | object | 用户信息对象 |
| data.user.id | string | 用户 ID |
| data.user.username | string\|null | 用户名 |
| data.user.phone | string | 手机号 |
| data.user.nickname | string | 昵称 |
| data.user.avatar | string\|null | 头像 URL |
| data.user.gender | number | 性别（0:未知, 1:男, 2:女） |
| data.user.last_login_at | number | 最后登录时间（时间戳） |
| data.user.created_at | number | 创建时间（时间戳） |
| data.user.updated_at | number | 更新时间（时间戳） |
| data.isNewUser | boolean | 是否为新用户 |
| data.last_family | object\|null | 最后访问的家庭信息 |
| data.last_family.id | string | 家庭 ID |
| data.last_family.name | string | 家庭名称 |
| data.last_care_receiver | object\|null | 最后的照护对象 |
| data.last_care_receiver.id | string | 照护对象 ID |
| data.last_care_receiver.name | string | 照护对象名称 |

## 使用示例

### 基本使用

```dart
import 'package:babylove_flutter/services/auth_service.dart';
import 'package:babylove_flutter/core/network/network.dart';

final authService = AuthService();

try {
  final response = await authService.loginWithSms(
    phone: '13800138000',
    code: '123456',
    nickname: '测试用户',
  );

  if (response.isSuccess && response.data != null) {
    // 登录成功
    final loginData = response.data!;
    print('Token: ${loginData.token}');
    print('用户: ${loginData.user.nickname}');
    
    // Token 会自动保存，后续请求会自动携带
  } else {
    // 登录失败
    print('登录失败: ${response.code}');
  }
} on NetworkException catch (e) {
  print('网络错误: ${e.message}');
}
```

### 在 Flutter Widget 中使用

```dart
import 'package:flutter/material.dart';
import 'package:babylove_flutter/services/auth_service.dart';
import 'package:babylove_flutter/core/network/network.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authService = AuthService();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_phoneController.text.isEmpty ||
        _codeController.text.isEmpty ||
        _nicknameController.text.isEmpty) {
      _showMessage('请填写完整信息');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.loginWithSms(
        phone: _phoneController.text,
        code: _codeController.text,
        nickname: _nicknameController.text,
      );

      if (response.isSuccess && response.data != null) {
        final loginData = response.data!;
        
        // 登录成功
        if (loginData.isNewUser) {
          // 新用户 - 可能需要引导完善资料
          Navigator.pushReplacementNamed(context, '/onboarding');
        } else {
          // 老用户 - 直接进入主页
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        _showMessage('登录失败: ${response.message ?? response.code}');
      }
    } on NetworkException catch (e) {
      _showMessage(e.message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('登录')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: '手机号'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(labelText: '验证码'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(labelText: '昵称'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('登录'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }
}
```

## 文件结构

```
lib/
├── models/
│   ├── user_model.dart              # User、Family、CareReceiver 模型
│   └── login_response_model.dart    # 登录响应和请求模型
├── services/
│   ├── auth_service.dart            # 认证服务（登录、退出等）
│   └── auth_service_example.dart    # 使用示例
└── core/
    └── network/
        ├── response_model_string_code.dart  # 支持字符串 code 的响应模型
        └── ...
```

## 注意事项

1. **Token 管理**：登录成功后，Token 会自动保存在 HttpClient 中，后续的 API 请求会自动在请求头中携带 `Authorization: Bearer {token}`

2. **登录状态持久化**：建议将 Token 保存到本地存储（如 SharedPreferences 或 FlutterSecureStorage），以便应用重启后恢复登录状态

3. **新用户处理**：根据 `isNewUser` 字段判断是否为新用户，可以为新用户提供引导流程

4. **家庭和照护对象**：`last_family` 和 `last_care_receiver` 可能为 null，需要进行判空处理

5. **错误处理**：务必捕获并处理 `NetworkException`，为用户提供友好的错误提示

## 相关接口

- 退出登录：调用 `authService.logout()` 清除 Token
- 检查登录状态：调用 `authService.isLoggedIn()` 判断是否已登录
- 获取 Token：调用 `authService.getToken()` 获取当前 Token

## 更多示例

查看 `lib/services/auth_service_example.dart` 获取完整的使用示例。
