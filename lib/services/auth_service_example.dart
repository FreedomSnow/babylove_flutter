import 'package:babylove_flutter/core/network/network.dart';
import 'package:babylove_flutter/services/auth_service.dart';

/// 认证服务使用示例
class AuthServiceExample {
  final AuthService _authService = AuthService();

  /// 示例 1: 短信登录
  Future<void> loginExample() async {
    try {
      final response = await _authService.loginWithSms(
        phone: '13800138000',
        code: '123456',
        nickname: '测试用户',
      );

      if (response.isSuccess && response.data != null) {
        print('登录成功！');
        print('Token: ${response.data!.token}');
        print('用户信息: ${response.data!.user}');
        print('是否新用户: ${response.data!.isNewUser}');
        
        if (response.data!.lastFamily != null) {
          print('最后访问的家庭: ${response.data!.lastFamily}');
        }
        
        if (response.data!.lastCareReceiver != null) {
          print('最后照护对象: ${response.data!.lastCareReceiver}');
        }
      } else {
        print('登录失败: ${response.code} - ${response.message}');
      }
    } on NetworkException catch (e) {
      print('网络错误: ${e.message}');
    } catch (e) {
      print('未知错误: $e');
    }
  }

  /// 示例 2: 检查登录状态
  void checkLoginStatusExample() {
    if (_authService.isLoggedIn()) {
      print('用户已登录');
      print('当前 Token: ${_authService.getToken()}');
    } else {
      print('用户未登录');
    }
  }

  /// 示例 3: 退出登录
  Future<void> logoutExample() async {
    try {
      await _authService.logout();
      print('已退出登录');
    } catch (e) {
      print('退出登录失败: $e');
    }
  }

  /// 示例 4: 完整的登录流程
  Future<void> fullLoginFlowExample() async {
    // 1. 检查是否已登录
    if (_authService.isLoggedIn()) {
      print('用户已登录，无需重新登录');
      return;
    }

    // 2. 执行登录
    try {
      print('开始登录...');
      final response = await _authService.loginWithSms(
        phone: '13800138000',
        code: '123456',
        nickname: '测试用户',
      );

      // 3. 处理登录结果
      if (response.isSuccess && response.data != null) {
        final loginData = response.data!;
        
        print('✓ 登录成功');
        print('用户ID: ${loginData.user.id}');
        print('昵称: ${loginData.user.nickname}');
        print('手机: ${loginData.user.phone}');
        
        // 4. 根据是否为新用户执行不同的逻辑
        if (loginData.isNewUser) {
          print('欢迎新用户！请完善个人信息');
          // 可以跳转到完善资料页面
        } else {
          print('欢迎回来！');
          // 可以跳转到主页
          
          // 5. 如果有最后访问的家庭和照护对象，可以直接使用
          if (loginData.lastFamily != null && loginData.lastCareReceiver != null) {
            print('恢复到上次访问的家庭: ${loginData.lastFamily!.name}');
            print('照护对象: ${loginData.lastCareReceiver!.name}');
          }
        }
      } else {
        print('✗ 登录失败');
        print('错误码: ${response.code}');
        print('错误信息: ${response.message ?? "未知错误"}');
        // 可以显示错误提示给用户
      }
    } on NetworkException catch (e) {
      print('✗ 网络请求失败');
      print('错误: ${e.message}');
      // 显示网络错误提示
    } catch (e) {
      print('✗ 发生未知错误');
      print('错误: $e');
      // 显示通用错误提示
    }
  }

  /// 示例 5: 从本地存储恢复登录状态
  Future<void> restoreLoginStateExample() async {
    // 假设从 SharedPreferences 或 SecureStorage 中获取到保存的 token
    final savedToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
    
    if (savedToken.isNotEmpty) {
      // 恢复 token
      _authService.setToken(savedToken);
      print('已恢复登录状态');
      
      // 可以选择验证 token 是否仍然有效
      // 例如：调用获取用户信息接口
    }
  }
}

/// 在应用中使用示例
void main() async {
  final example = AuthServiceExample();
  
  // 执行完整的登录流程
  await example.fullLoginFlowExample();
  
  // 检查登录状态
  example.checkLoginStatusExample();
  
  // 退出登录
  await example.logoutExample();
}
