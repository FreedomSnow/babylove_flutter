# 短信验证码接口文档

## 发送验证码

### 接口信息

- **接口地址**: `/api/auth/sms/send`
- **请求方法**: `POST`
- **内容类型**: `application/json`

### 请求参数

```json
{
  "phone": "13800138000"
}
```

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| phone | string | 是 | 手机号码 |

### 响应数据

#### 成功响应

```json
{
  "code": "NO_ERROR",
  "data": {
    "code": "123456",
    "description": "验证码（⚠️ 仅开发环境返回，生产环境此字段不存在）"
  }
}
```

| 字段名 | 类型 | 说明 |
|--------|------|------|
| code | string | 状态码 |
| data.code | string | 验证码（仅开发环境） |
| data.description | string | 字段说明 |

⚠️ **注意**: `data.code` 字段仅在开发环境返回，用于调试。生产环境不会返回验证码内容。

#### 错误响应

```json
{
  "code": "ERROR_CODE",
  "message": "错误信息"
}
```

### 使用示例

```dart
import 'package:babylove_flutter/services/auth_service.dart';

final authService = AuthService();

try {
  // 发送验证码
  final response = await authService.sendSmsCode(
    phone: '13800138000',
  );

  if (response.isSuccess) {
    print('验证码发送成功');
    
    // 开发环境可以获取验证码
    if (response.data?.code != null) {
      print('验证码: ${response.data!.code}');
    }
  } else {
    print('发送失败: ${response.message}');
  }
} catch (e) {
  print('发送异常: $e');
}
```

### 常见错误码

| 错误码 | 说明 | 处理建议 |
|--------|------|----------|
| PHONE_INVALID | 手机号格式不正确 | 检查手机号格式 |
| SMS_SEND_FREQUENTLY | 发送过于频繁 | 等待一段时间后重试 |
| SMS_SEND_LIMIT | 达到发送上限 | 24小时后重试 |
| NETWORK_ERROR | 网络错误 | 检查网络连接 |

### 流程说明

1. 用户输入手机号
2. 客户端验证手机号格式
3. 调用发送验证码接口
4. 服务端发送短信
5. 客户端启动倒计时（60秒）
6. 用户收到短信验证码
7. 用户输入验证码进行登录

### 安全建议

- 客户端应限制验证码发送频率（60秒倒计时）
- 服务端应限制单个手机号的发送次数
- 验证码应设置有效期（通常5-10分钟）
- 生产环境不应返回验证码内容
