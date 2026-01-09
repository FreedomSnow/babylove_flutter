import 'package:flutter/material.dart';
import 'package:babylove_flutter/services/auth_service.dart';
import 'package:babylove_flutter/services/storage_service.dart';
import 'package:babylove_flutter/services/family_service.dart';
import 'package:babylove_flutter/services/app_state_service.dart';
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
  // 控制加载状态和重试按钮显示
  bool _isLoading = true;
  bool _loadFailed = false;
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  /// 检查登录状态
  Future<void> _checkLoginStatus() async {
    // 延迟一下，给用户一个启动动画的体验
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadFailed = false;
      });
    }

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
        // 登录成功后，尝试加载用户相关的家庭数据并更新全局状态
        final ok = await _loadUserFamiliesAndData();
        if (ok) {
          _navigateToHome();
        } else {
          // 加载失败：隐藏指示器并显示重试按钮
          if (mounted) {
            setState(() {
              _isLoading = false;
              _loadFailed = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('获取数据失败')),
            );
          }
        }
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      // 出错则跳转到登录页
      _navigateToLogin();
    }
  }

  /// 通用方法：获取我的家庭并根据 lastFamily 加载家庭数据，更新 AppStateService
  /// 返回 true 表示全部成功，false 表示任一步骤失败
  Future<bool> _loadUserFamiliesAndData() async {
    try {
      final familyService = FamilyService();
      final appState = AppStateService();

      // 1. 获取我的家庭列表
      final familiesResp = await familyService.getMyFamilies();
      if (!familiesResp.isSuccess) {
        return false;
      }

      final families = familiesResp.data ?? [];
      appState.setMyFamilies(families);

      // 2. 如果有最近使用的家庭，则加载该家庭的成员和被照顾者数据
      if (appState.lastFamily != null) {
        final lastFamily = appState.lastFamily!;
        final dataResp = await familyService.loadFamilyData(familyId: lastFamily.id);
        if (!dataResp.isSuccess) {
          return false;
        }

        final fd = dataResp.data!;
        appState.updateFamilyMembersAndCareReceivers(
          familyId: lastFamily.id,
          careReceivers: fd.careReceivers,
          members: fd.members,
        );
      }

      return true;
    } catch (e) {
      debugPrint('Error loading families/data: $e');
      return false;
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
            
            const SizedBox(height: 48),
            
            // 加载指示器 / 重试按钮
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_loadFailed)
              ElevatedButton.icon(
                onPressed: _checkLoginStatus,
                icon: const Icon(Icons.refresh),
                label: const Text('重新加载数据'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 30,
                    top: 12,
                    bottom: 12,
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
