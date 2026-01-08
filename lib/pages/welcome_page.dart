import 'package:flutter/material.dart';
import 'package:babylove_flutter/services/family_service.dart';
import 'package:babylove_flutter/services/app_state_service.dart';
import 'package:babylove_flutter/core/network/network_exception.dart';
import 'package:babylove_flutter/pages/create_family_page.dart';
import 'main_page.dart';

/// 欢迎页面 - 用于创建或加入家庭
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _familyService = FamilyService();

  /// 跳转到创建家庭页面
  void _goToCreateFamilyPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateFamilyPage()),
    );
  }

  /// 显示加入家庭对话框
  void _showJoinFamilyDialog() {
    final formKey = GlobalKey<FormState>();
    final nicknameController = TextEditingController();
    final inviteCodeController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: const Text('加入家庭'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 昵称
                  TextFormField(
                    controller: nicknameController,
                    decoration: InputDecoration(
                      labelText: '我在家庭中的昵称',
                      hintText: '请输入您的昵称',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入您的昵称';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 邀请码
                  TextFormField(
                    controller: inviteCodeController,
                    decoration: InputDecoration(
                      labelText: '邀请码',
                      hintText: '请输入邀请码',
                      prefixIcon: const Icon(Icons.qr_code),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入邀请码';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              SizedBox(
                width: 90,
                height: 40,
                child: OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('取消', style: TextStyle(fontSize: 16)),
                ),
              ),
              SizedBox(
                width: 90,
                height: 40,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setDialogState(() {
                              isLoading = true;
                            });

                            try {
                              final response = await _familyService.joinFamily(
                                inviteCode: inviteCodeController.text.trim(),
                                nickname: nicknameController.text.trim(),
                              );

                              if (response.isSuccess && response.data != null) {
                                // 保存家庭到全局状态
                                AppStateService().setLastFamily(
                                  response.data!.family,
                                );

                                if (mounted) {
                                  Navigator.of(context).pop();
                                  _showSnackBar('加入家庭成功', Colors.green);

                                  // TODO: 如果家庭已有护理对象，可能需要选择或创建
                                  // 暂时先跳转到主页
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const MainPage(),
                                    ),
                                  );
                                }
                              } else {
                                if (mounted) {
                                  _showSnackBar(
                                    '加入失败: ${response.message}',
                                    Colors.red,
                                  );
                                }
                              }
                            } on NetworkException catch (e) {
                              if (mounted) {
                                _showSnackBar('加入失败: ${e.message}', Colors.red);
                              }
                            } catch (e) {
                              if (mounted) {
                                _showSnackBar('加入失败: $e', Colors.red);
                              }
                            } finally {
                              if (mounted) {
                                setDialogState(() {
                                  isLoading = false;
                                });
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('加入', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 显示提示信息
  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appName = '幼安管家'; // 应用名称

    return Scaffold(
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
