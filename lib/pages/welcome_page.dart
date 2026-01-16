import 'package:flutter/material.dart';
import 'package:babylove_flutter/pages/create_family_page.dart';
import 'package:babylove_flutter/widgets/join_family_dialog.dart';
import 'main_page.dart';

/// 欢迎页面 - 用于创建或加入家庭
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  /// 跳转到创建家庭页面
  void _goToCreateFamilyPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateFamilyPage()),
    );
  }

  /// 显示加入家庭对话框
  void _showJoinFamilyDialog() async {
    final joined = await showJoinFamilyDialog(context);
    if (joined && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appName = '幼安管家'; // 应用名称

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 80),

              // 应用图标
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 40),

              // 欢迎文本
              Text(
                '欢迎使用$appName',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                '请先创建或加入一个家庭',
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // 创建家庭按钮
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _goToCreateFamilyPage,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text(
                    '创建家庭',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 分割线 "或者"
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).dividerTheme.color,
                      thickness: 1,
                      endIndent: 12,
                    ),
                  ),
                  Text(
                    '或者',
                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).dividerTheme.color,
                      thickness: 1,
                      indent: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 加入家庭按钮
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _showJoinFamilyDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.group_add),
                  label: const Text(
                    '加入家庭',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
