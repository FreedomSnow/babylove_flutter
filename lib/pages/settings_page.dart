import 'package:babylove_flutter/core/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/elder_mode_provider.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'feedback_page.dart';
import 'login_page.dart';

/// 设置页面
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showThemeSelector(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '选择主题',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...AppTheme.values.map((theme) {
              String themeName;
              IconData themeIcon;
              
              switch (theme) {
                case AppTheme.light:
                  themeName = '浅色主题';
                  themeIcon = Icons.light_mode;
                  break;
                case AppTheme.dark:
                  themeName = '深色主题';
                  themeIcon = Icons.dark_mode;
                  break;
                case AppTheme.blue:
                  themeName = '蓝色主题';
                  themeIcon = Icons.water_drop;
                  break;
                case AppTheme.pink:
                  themeName = '粉色主题';
                  themeIcon = Icons.favorite;
                  break;
              }
              
              return ListTile(
                leading: Icon(themeIcon),
                title: Text(themeName),
                trailing: themeProvider.currentTheme == theme
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  themeProvider.setTheme(theme);
                  Navigator.pop(context);
                },
              );
            }).toList(),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('退出'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      // 显示半透明全屏加载遮罩
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.35),
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await AuthService().logout();
        await StorageService().clearTokens();

        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      } catch (e) {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        if (context.mounted) {
          AppUtils.showInfoToast(
            context,
            message: '退出登录失败: ${e.toString()}',
            type: ToastType.error,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          
          // 老年模式
          Consumer<ElderModeProvider>(
            builder: (context, elderModeProvider, child) {
              return SwitchListTile(
                secondary: const Icon(Icons.accessibility_new),
                title: const Text('老年模式'),
                subtitle: const Text('开启后字体会更大，更易阅读'),
                value: elderModeProvider.isElderMode,
                onChanged: (value) {
                  elderModeProvider.setElderMode(value);
                },
              );
            },
          ),

          const Divider(),

          // 主题选择
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('主题'),
            subtitle: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                String themeName;
                switch (themeProvider.currentTheme) {
                  case AppTheme.light:
                    themeName = '浅色主题';
                    break;
                  case AppTheme.dark:
                    themeName = '深色主题';
                    break;
                  case AppTheme.blue:
                    themeName = '蓝色主题';
                    break;
                  case AppTheme.pink:
                    themeName = '粉色主题';
                    break;
                }
                return Text(themeName);
              },
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeSelector(context),
          ),

          const Divider(),

          // 反馈
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('意见反馈'),
            subtitle: const Text('告诉我们您的想法'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedbackPage()),
              );
            },
          ),

          const Divider(),

          // 关于
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于'),
            subtitle: const Text('版本 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: '宝贝爱',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.favorite, size: 48, color: Colors.pink),
                children: [
                  const Text('一款专注于家庭照护的应用'),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          // 退出登录
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                '退出登录',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _logout(context),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
