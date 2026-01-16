import 'package:babylove_flutter/core/utils.dart';
import 'package:babylove_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';

/// 反馈页面
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _contentController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // 显示全屏半透明加载遮罩
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final contact = _emailController.text.trim();
    final content = _contentController.text.trim();

    try {
      final resp = await _authService.submitFeedback(contact: contact, content: content);

      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (!mounted) return;

      if (resp.isSuccess) {
        AppUtils.showInfoToast(
          context,
          message: '反馈提交成功，感谢您的支持！',
          type: ToastType.success,
        );
        Navigator.pop(context);
      } else {
        AppUtils.showInfoToast(
          context,
          message: resp.message ?? '反馈提交失败',
          type: ToastType.error,
        );
      }
    } catch (e) {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (!mounted) return;
      AppUtils.showInfoToast(
        context,
        message: '反馈提交失败: ${e.toString()}',
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('意见反馈'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 说明文本
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '您的反馈对我们很重要！\n我们会认真阅读每一条反馈。',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[900],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 邮箱（可选）
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: '邮箱（可选）',
                hintText: '用于接收我们的回复',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
                helperText: '如需我们回复，请留下您的邮箱',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return '请输入有效的邮箱地址';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // 反馈内容
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: '反馈内容',
                hintText: '请详细描述您的问题或建议...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.edit),
                alignLabelWithHint: true,
                helperText: '最多300字',
                counterText: '${_contentController.text.length}/300',
              ),
              maxLines: 8,
              maxLength: 300,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入反馈内容';
                }
                if (value.trim().length < 10) {
                  return '反馈内容至少需要10个字符';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {});
              },
            ),

            const SizedBox(height: 24),

            // 提交按钮
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '提交反馈',
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 16),

            // 提示信息
            Center(
              child: Text(
                '我们承诺保护您的隐私',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
