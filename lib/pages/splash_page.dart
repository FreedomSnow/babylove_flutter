import 'package:flutter/material.dart';
import 'package:babylove_flutter/services/auth_service.dart';
import 'package:babylove_flutter/services/storage_service.dart';
import 'login_page.dart';
import 'main_page.dart';

/// 启动页（Splash Page）
/// 用于检查用户登录状态
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  /// 检查登录状态
  Future<void> _checkLoginStatus() async {
    // 延迟一下，给用户一个启动动画的体验
    await Future.delayed(const Duration(seconds: 1));

    try {
      // 从本地存储获取 token
      final token = await StorageService().getToken();

      if (token == null || token.isEmpty) {
        // 没有 token，跳转到登录页
        _navigateToLogin();
        return;
      }

      // 有 token，设置到 AuthService
      final authService = AuthService();
      authService.setToken(token);

      // TODO: 可以在这里调用一个验证 token 的接口
      // 如果 token 有效，跳转到主页；否则跳转到登录页
      // 这里暂时假设 token 有效
      
      // 检查 token 是否仍然有效
      if (authService.isLoggedIn()) {
        _navigateToHome();
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      // 出错则跳转到登录页
      _navigateToLogin();
    }
  }

  /// 跳转到登录页
  void _navigateToLogin() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  /// 跳转到主页
  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 应用图标
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            
            // 应用名称
            const Text(
              '幼安管家',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              'YouAn Butler',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 48),
            
            // 加载指示器
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
